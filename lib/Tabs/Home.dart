import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:my_expense_manager/Common/common.dart';
import 'package:my_expense_manager/constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Common/preferences.dart';
import '../DatabaseHandler/DbHelper.dart';
import '../Model/transactionsModel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  DateTime? _selectedDate;
  int userId = 0;

  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  List<TransactionModel> transactionList = [];
  bool isOneDay = true;
  List<String> sortBy = ["Today's transactions", "All transactions "];

  @override
  void initState() {
    getUser();
    super.initState();
  }

  getUser() async {
    userId = await preferences.getPreference('user_id', 0);
    print("userId ${userId}");
    await _updateUserTransactionsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: SpeedDial(
        icon: Icons.currency_pound,
        activeIcon: Icons.close,
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        activeBackgroundColor: kPrimaryColor,
        activeForegroundColor: Colors.white,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        childMargin: const EdgeInsets.all(20),
        elevation: 1.0,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.remove),
            backgroundColor: Colors.white,
            foregroundColor: kPrimaryColor,
            label: Debit,
            labelStyle: const TextStyle(fontSize: 14.0),
            onTap: () {
              showCustomDialog(context, Debit);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.white,
            foregroundColor: kPrimaryColor,
            label: Credit,
            labelStyle: const TextStyle(fontSize: 14.0),
            onTap: () {
              showCustomDialog(context, Credit);
            },
          ),
        ],
      ),
      body: transactionList.isNotEmpty
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      isOneDay == true ? isOneDay = false : isOneDay = true;
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        isOneDay == true ? "Show all" : "Show recent",
                        maxLines: 1,
                        style:
                            const TextStyle(fontSize: 14, color: kPrimaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 75),
                        itemBuilder: (context, index) {
                          final item = transactionList[index].id;
                          return Dismissible(
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.all(15),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            key: Key(item.toString()),
                            onDismissed: (direction) {
                              print(transactionList[index].id);
                              DbHelper.instance.deleteTransactions(
                                  userId, transactionList[index].id!);
                              transactionList.remove(transactionList[index]);
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: kPrimaryColor,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transactionList[index]
                                              .title!
                                              .capitalize(),
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: kPrimaryColor),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Text(
                                          DateFormat('d MMM yyyy').format(
                                              DateTime.parse(
                                                  transactionList[index]
                                                      .date!)),
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      transactionList[index]
                                                  .transaction_type! ==
                                              Credit
                                          ? "+ £${transactionList[index].amount!}"
                                          : "- £${transactionList[index].amount!}",
                                      style: const TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: isOneDay == false
                            ? transactionList.length
                            : transactionList.length > 10
                                ? 10
                                : transactionList.length),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text(
                "No transaction found",
                style: TextStyle(fontSize: 18, color: kPrimaryColor),
              ),
            ),
    );
  }

  showCustomDialog(BuildContext context, String type) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0)), //this right here
          child: Container(
            height: MediaQuery.of(context).size.height * 0.43,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () {
                      titleController.clear();
                      amountController.clear();
                      dateController.clear();
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close, color: kPrimaryColor)),
                const SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      filled: false,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      prefixIcon: Icon(Icons.title),
                      hintText: "Enter a title",
                      hintStyle: TextStyle(fontWeight: FontWeight.normal)),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                      filled: false,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      prefixIcon: Icon(Icons.currency_pound),
                      hintText: "Enter an amount",
                      hintStyle: TextStyle(fontWeight: FontWeight.normal)),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                        enabled: false,
                        filled: false,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                        hintText: "Select a date",
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black54)),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                InkWell(
                  onTap: () {
                    _addNewTransaction(
                        titleController.text,
                        double.parse(amountController.text),
                        _selectedDate!,
                        type);

                    titleController.clear();
                    amountController.clear();
                    dateController.clear();

                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      'Add',
                      style: TextStyle(color: kPrimaryColor, fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(1900, 1),
      lastDate: today,
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        dateController.value =
            TextEditingValue(text: DateFormat('d/M/y').format(pickedDate));
      });
    }
  }

  _addNewTransaction(
      String title, double amount, DateTime chosenDate, String type) async {
    final newTxn = TransactionModel(
      userId,
      title,
      amount,
      type,
      DateFormat('yyyy-MM-dd').format(chosenDate),
    );
    int res = await DbHelper.instance.insertTransaction(newTxn);

    if (res != 0) {
      await _updateUserTransactionsList();
    }
  }

  _updateUserTransactionsList() async {
    Future<List<TransactionModel>> res =
        DbHelper.instance.getAllTransactions(userId);
    transactionList = await res;
    transactionList = transactionList.reversed.toList();
    for (var a in transactionList) {
      print(a.id);
      print(a.title);
    }
    setState(() {});
  }

  int getRandom() {
    var intValue = Random().nextInt(10);
    intValue = Random().nextInt(100) + 50;
    return intValue;
  }
}
