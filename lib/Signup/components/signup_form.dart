import 'package:flutter/material.dart';
import 'package:my_expense_manager/Common/common.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Common/comHelper.dart';
import '../../DatabaseHandler/DbHelper.dart';
import '../../Login/login_screen.dart';
import '../../Model/UserModel.dart';
import '../../dashboard/dashboard.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _conUserName = TextEditingController();
  final _conPassword = TextEditingController();
  final _conCPassword = TextEditingController();
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper.instance;
  }

  signUp() async {
    String uname = _conUserName.text;
    String passwd = _conPassword.text;
    String cpasswd = _conCPassword.text;

    if (_formKey != null && _formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        if (passwd != cpasswd) {
          alertDialog(context, 'Password Mismatch');
        } else {
          _formKey.currentState!.save();

          UserModel uModel = UserModel(uname, passwd);
          await dbHelper.saveData(uModel).then((userData) {
            alertDialog(context, "Successfully Saved");


            CallNextScreenAndClearStack(context, LoginScreen());
          }).catchError((error) {
            print(error);
            alertDialog(context, "Error: Data Save Fail");
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            controller: _conUserName,
            decoration: const InputDecoration(
              hintText: "Your username",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          TextFormField(
            controller: _conPassword,
            textInputAction: TextInputAction.next,
            obscureText: true,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Your password",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          TextFormField(
            controller: _conCPassword,
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Your confirm password",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.lock),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () {
              signUp();
            },
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
