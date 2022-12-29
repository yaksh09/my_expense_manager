import 'package:flutter/material.dart';
import 'package:my_expense_manager/constants.dart';

import '../Common/common.dart';
import '../Model/ratesModel.dart';
import 'anyToAny.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({Key? key}) : super(key: key);

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  late Future<RatesModel> result;
  late Future<Map> allcurrencies;

  @override
  void initState() {
    super.initState();
    setState(() {
      result = fetchrates();
      allcurrencies = fetchcurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RatesModel>(
        future: result,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor)));
          }
          return Center(
            child: FutureBuilder<Map>(
                future: allcurrencies,
                builder: (context, currSnapshot) {
                  if (currSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor));
                  }
                  return AnyToAny(
                    currencies: currSnapshot.data!,
                    rates: snapshot.data!.rates,
                  );
                }),
          );
        },
      ),
    );
  }
}
