import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/ratesModel.dart';
import 'package:http/http.dart' as http;

const String key = 'da753eef024344109b856fb09351271a';

void CallNextScreen(BuildContext context, StatefulWidget nextScreen) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => nextScreen,
        settings: RouteSettings(name: nextScreen.toString())),
  );
}

void CallNextScreenClearOld(BuildContext context, StatefulWidget nextScreen) {
  //AnalyticsService().setEventName(nextScreen.toStringShort());
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => nextScreen,
        settings: RouteSettings(name: nextScreen.toString())),
  );
}

void CallNextScreenAndClearStack(
    BuildContext context, StatefulWidget nextScreen) {
  //AnalyticsService().setEventName(nextScreen.toStringShort());
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => nextScreen,
          settings: RouteSettings(name: nextScreen.toString())),
      (Route<dynamic> route) => false);
}

Future CallNextScreenWithResult(
    BuildContext context, StatefulWidget nextScreen) async {
  //AnalyticsService().setEventName(nextScreen.toStringShort());
  var action = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => nextScreen,
          settings: RouteSettings(name: nextScreen.toString())));
  return action;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

Future<RatesModel> fetchrates() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/latest.json?base=USD&app_id=' + key));
  final result = ratesModelFromJson(response.body);
  return result;
}

Future<Map> fetchcurrencies() async {
  var response = await http.get(Uri.parse(
      'https://openexchangerates.org/api/currencies.json?app_id=' + key));
  final allCurrencies = allCurrenciesFromJson(response.body);
  return allCurrencies;
}

Map<String, String> allCurrenciesFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) => MapEntry<String, String>(k, v));

String allCurrenciesToJson(Map<String, String> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v)));

String convertusd(Map exchangeRates, String usd, String currency) {
  String output =
      ((exchangeRates[currency] * double.parse(usd)).toStringAsFixed(2))
          .toString();
  return output;
}

String convertany(Map exchangeRates, String amount, String currencybase,
    String currencyfinal) {
  String output = (double.parse(amount) /
          exchangeRates[currencybase] *
          exchangeRates[currencyfinal])
      .toStringAsFixed(2)
      .toString();

  return output;
}
