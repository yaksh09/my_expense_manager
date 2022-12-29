import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_expense_manager/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Common/preferences.dart';
import 'constants.dart';
import 'dashboard/dashboard.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String userName = "";
  int userId = 0;
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    getUser();
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => userName != "" && userId != 0
                    ? const DashBoard()
                    : const LoginScreen())));
  }

  getUser() async {
    userName = await preferences.getPreference('user_name', '');
    userId = await preferences.getPreference('user_id', 0);

    print(userName);
    print(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Image.asset(
          logo,
        ));
  }
}
