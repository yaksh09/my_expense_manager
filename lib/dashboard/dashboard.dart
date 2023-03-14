import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_expense_manager/Login/login_screen.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Common/common.dart';
import '../Common/preferences.dart';
import '../DatabaseHandler/DbHelper.dart';
import '../Model/transactionsModel.dart';
import '../Tabs/CurrencyConverter.dart';
import '../Tabs/Home.dart';
import '../Tabs/ChartView.dart';
import '../constants.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _selectedIndex = 0;
  String userName = "";
  int userId = 0;
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    ChartView(),
    CurrencyConverter()
  ];
  List<TransactionModel> transactionList = [];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    userName = await preferences.getPreference('user_name', '');
    userId = await preferences.getPreference('user_id', 0);
    await _updateUserTransactionsList();
  }

  _updateUserTransactionsList() async {
    Future<List<TransactionModel>> res =
        DbHelper.instance.getAllTransactions(userId);
    transactionList = await res;
    transactionList = transactionList.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        actions: [
          InkWell(
            onTap: () {
              shareViaWhatsApp();
            },
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.whatsapp),
            ),
          ),
          InkWell(
            onTap: () {
              showUserBottomSheet();
            },
            child: Container(
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.person),
            ),
          )
        ],
        title: const Text('My Expense Manager', style: TextStyle(fontSize: 16)),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.align_vertical_bottom,
                  text: 'Graph',
                ),
                GButton(
                  icon: Icons.currency_exchange_outlined,
                  text: 'Converter',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  shareViaWhatsApp() async {
    final pdf = pw.Document();
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(children: [
        pw.Text(
          "My EXPENSE MANAGER",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            child: pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.grey),
              children: renderDetailRow(),
            ))
      ]);
    }));

    Directory(appDocDirectory.path + '/' + 'dir')
        .create(recursive: true)
        .then((Directory directory) {
      print('Path of New Dir: ' + directory.path);

      final file = File('${directory.path}/${DateTime.now()}.pdf');
      file.create(recursive: true).then((value) async {
        await file.writeAsBytes(await pdf.save()).then((value) {
          FlutterShare.shareFile(
            title: "My EXPENSE MANAGER",
            filePath: value.path,
          );
        });
      });
    });
  }

  List<pw.TableRow> renderDetailRow() {
    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          // pw.Text("  "),
          pw.Text(
            "Date",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.Text(
            "Type",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.Text(
            "Amount",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.Text(
            "Description",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ]));
    for (int i = 0; i < transactionList.length; i++) {
      // if (temp[i].companyValues != null && temp[i].companyValues!.isNotEmpty) {
      rows.add(pw.TableRow(children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            transactionList[i].date!,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            transactionList[i].transaction_type!,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            transactionList[i].amount!.toString(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(
            transactionList[i].title!,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14),
          ),
        ),
      ]));
      // }
    }
    return rows;
  }

  showUserBottomSheet() {
    showModalBottomSheet(
        isDismissible: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: false,
        enableDrag: false,
        builder: (ctx) {
          return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  Row(
                    children: [
                      MaterialButton(
                        onPressed: () {},
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      Text(userName.toUpperCase(),
                          style: const TextStyle(
                              color: kPrimaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        preferences.removeKeyFromPreference('user_name');
                        preferences.removeKeyFromPreference('user_id');

                        CallNextScreenClearOld(context, const LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        side: const BorderSide(color: kPrimaryColor),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ));
        });
  }
}
