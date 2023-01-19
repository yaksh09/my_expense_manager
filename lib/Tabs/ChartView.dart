import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Common/preferences.dart';
import '../DatabaseHandler/DbHelper.dart';
import '../Model/transactionsModel.dart';
import '../constants.dart';

class ChartView extends StatefulWidget {
  const ChartView({Key? key}) : super(key: key);

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  DateFormat inputFormat = DateFormat('dd MMM yy');
  late TooltipBehavior _tooltipBehavior;
  List<TransactionModel> transactionList = [];
  int userId = 0;
  List<ChartData> debitList = [];
  List<ChartData> creditList = [];

  Map<String, ChartData2> customMap = {};

  @override
  void initState() {
    getUser();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  getUser() async {
    userId = await preferences.getPreference('user_id', 0);
    print("userId ${userId}");
    await _updateUserTransactionsList();
  }

  _updateUserTransactionsList() async {
    Future<List<TransactionModel>> res =
        DbHelper.instance.getAllTransactions(userId);
    transactionList = await res;
    transactionList = transactionList.reversed.toList();
    print("LENGTH=== ${transactionList.length}");
    getShortedList();
  }

  getShortedList() {
    transactionList.sort((a, b) {
      var adate = a.date;
      var bdate = b.date;
      return bdate!.compareTo(adate!);
    });

    print("SORTEDLIST");

    for (int i = 0; i < transactionList.length; i++) {
      print(transactionList[i].date);
    }
    print("SORTEDLIST-------------");

    for (int i = 0; i < transactionList.length; i++) {
      if ((customMap == null || customMap.isEmpty) ||
          customMap.isNotEmpty &&
              !customMap.containsKey(transactionList[i].date!)) {
        var type = transactionList[i].transaction_type;
        ChartData2 temp;
        if (type == Debit) {
          temp = ChartData2(DateTime.parse(transactionList[i].date!), 0,
              transactionList[i].amount!);
        } else {
          temp = ChartData2(DateTime.parse(transactionList[i].date!),
              transactionList[i].amount!, 0);
        }

        customMap[transactionList[i].date!] = temp;
      } else {
        print("INELSEE=====>>>>>");
        var type = transactionList[i].transaction_type;
        ChartData2 temp;

        if (type == Debit) {
          var tempValue = customMap[transactionList[i].date!]!.drValue;
          print("EDITDEBIT===$tempValue");
          temp = ChartData2(
              DateTime.parse(transactionList[i].date!),
              customMap[transactionList[i].date!]!.crValue,
              tempValue + transactionList[i].amount!);
        } else {
          var tempValue = customMap[transactionList[i].date!]!.crValue;
          print("EDITCREADIT===$tempValue");
          temp = ChartData2(
              DateTime.parse(transactionList[i].date!),
              tempValue + transactionList[i].amount!,
              customMap[transactionList[i].date!]!.drValue);
        }

        customMap[transactionList[i].date!] = temp;
      }
    }

    print(customMap.toString());

    customMap.values.forEach((element) {
      print("${element.date} ===== ${element.crValue} ===  ${element.drValue}");
    });

    customMap.values.forEach((element) {
      if (element.drValue != null && element.drValue != 0) {
        debitList.add(ChartData(element.date, element.drValue));
      }
      if (element.crValue != null && element.crValue != 0) {
        creditList.add(ChartData(element.date, element.crValue));
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCartesianChart(
            tooltipBehavior: _tooltipBehavior,
            zoomPanBehavior:
                ZoomPanBehavior(enablePinching: true, zoomMode: ZoomMode.y),
            primaryXAxis: DateTimeAxis(
              dateFormat: inputFormat,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            series: <ChartSeries<ChartData, DateTime>>[
          BarSeries<ChartData, DateTime>(
              dataSource: creditList,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              width: 0.6,
              name: Credit,
              color: Colors.green,
              spacing: 0.3),
          BarSeries<ChartData, DateTime>(
              dataSource: debitList,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              width: 0.6,
              name: Debit,
              color: Colors.red,
              spacing: 0.3)
        ]));
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}

class ChartData2 {
  ChartData2(this.date, this.crValue, this.drValue);

  final DateTime date;
  final double crValue;
  final double drValue;
}
