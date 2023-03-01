import 'package:flutter/material.dart';
import 'package:my_expense_manager/dashboard/videoPlayerView.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import '../../Common/comHelper.dart';
import '../../Common/preferences.dart';
import '../../DatabaseHandler/DbHelper.dart';
import '../../Model/UserModel.dart';
import '../../Signup/signup_screen.dart';
import '../../components/already_have_an_account_acheck.dart';
import '../../dashboard/dashboard.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final _formKey = GlobalKey<FormState>();

  final _conUserName = TextEditingController();
  final _conPassword = TextEditingController();
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper.instance;
  }

  login() async {
    String uname = _conUserName.text;
    String passwd = _conPassword.text;

    if (uname.isEmpty) {
      alertDialog(context, "Please Enter User Name");
    } else if (passwd.isEmpty) {
      alertDialog(context, "Please Enter Password");
    } else {
      await dbHelper.getLoginUser(uname, passwd).then((userData) async {
        if (userData != null) {
          setSP(userData).whenComplete(() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashBoard()),
                (Route<dynamic> route) => false);
            print("SUCCESS");
          });
        } else {
          alertDialog(context, "Error: User Not Found");
        }
      }).catchError((error) {
        print(error);
        alertDialog(context, "Error: Login Fail");
      });
    }
  }

  Future setSP(UserModel user) async {
    // final SharedPreferences sp = await _pref;
    // sp.setInt("user_id", user.user_id);
    // sp.setString("user_name", user.user_name);
    // sp.setString("password", user.password);
    //
    print("USERRR====${user.user_id}");

    await preferences.setPreference("user_id", user.user_id);
    await preferences.setPreference("user_name", user.user_name);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: _conPassword,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () {
                login();
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "demo",
            child: ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return  VideoPlayerView();
                    },
                  ),
                );
              },
              child: Text(
                "Demo".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
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
