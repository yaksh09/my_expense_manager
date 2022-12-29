import 'package:flutter/material.dart';

import '../Common/common.dart';

class AnyToAny extends StatefulWidget {
  final rates;
  final Map currencies;

  const AnyToAny({Key? key, @required this.rates, required this.currencies})
      : super(key: key);

  @override
  _AnyToAnyState createState() => _AnyToAnyState();
}

class _AnyToAnyState extends State<AnyToAny> {
  TextEditingController amountController = TextEditingController();

  String dropdownValue1 = 'AUD';
  String dropdownValue2 = 'AUD';
  String answer = 'Converted Currency will be shown here :)';

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Convert Any Currency',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 20),

          //TextFields for Entering USD
          TextFormField(
            key: const ValueKey('amount'),
            controller: amountController,
            decoration: const InputDecoration(hintText: 'Enter Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          DropdownButton<String>(
            value: dropdownValue1,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: 24,
            elevation: 16,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Colors.grey.shade400,
            ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue1 = newValue!;
              });
            },
            items: widget.currencies.keys
                .toSet()
                .toList()
                .map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 20),
              child: const Text('To')),
          DropdownButton<String>(
            value: dropdownValue2,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: 24,
            elevation: 16,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Colors.grey.shade400,
            ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue2 = newValue!;
              });
            },
            items: widget.currencies.keys
                .toSet()
                .toList()
                .map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                setState(() {
                  answer =
                      '${amountController.text} $dropdownValue1 ${convertany(widget.rates, amountController.text, dropdownValue1, dropdownValue2)} $dropdownValue2';
                });
              } else {
                setState(() {
                  answer = "Please enter amount first!";
                });
              }
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor)),
            child: const Text('Convert'),
          ),

          const SizedBox(height: 30),
          Text(answer)
        ],
      ),
    );
  }
}
