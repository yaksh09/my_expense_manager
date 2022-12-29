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
    for (int i = 0; i < transactionList.length; i++) {
      if (transactionList[i].transaction_type == Debit) {
        debitList.add(ChartData(
            DateTime.parse(DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(transactionList[i].date!))),
            transactionList[i].amount!));
      } else {
        creditList.add(ChartData(
            DateTime.parse(DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(transactionList[i].date!))),
            transactionList[i].amount!));
      }
    }




    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData(DateTime(2022, 12, 18), 1),
      ChartData(DateTime(2016, 1, 2), 11),
      ChartData(DateTime(2017, 3, 1), 9),
      ChartData(DateTime(2018, 4, 1), 14),
      ChartData(DateTime(2019, 5, 1), 10),
    ];

    final List<ChartData> chartData1 = [
      ChartData(DateTime(2015, 1, 1), 1),
      ChartData(DateTime(2016, 1, 2), 11),
      ChartData(DateTime(2017, 3, 1), 9),
      ChartData(DateTime(2018, 4, 1), 14),
      ChartData(DateTime(2019, 5, 1), 10),
    ];
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
