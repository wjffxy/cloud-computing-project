import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:makefriend/ConfirmScreen.dart';
import 'package:makefriend/RecommendationScreen.dart';
import 'package:makefriend/SignInScreen.dart';
import 'package:makefriend/SignUpScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var returnValue;
  UserState userState;
  double progress;


  @override
  void initState() {
    super.initState();
    doLoad();
    Cognito.registerCallback((value) {
      if (!mounted) return;
      setState(() {
        userState = value;
      });
    });
  }

  @override
  void dispose() {
    Cognito.registerCallback(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: '/', routes: {
      '/': (context) => SignInScreen(),
      '/signUp': (context) => SignUpScreen(),
      '/confirm': (context) => ConfirmScreen(),
      '/recommendation': (context) => RecommendationScreen()
    });
  }

  Future<void> doLoad() async {
    var value;
    try {
      
      value = await Cognito.initialize();
    } catch (e, trace) {
      print(e);
      print(trace);

      if (!mounted) return;
      setState(() {
        returnValue = e;
        progress = -1;
      });

      return;
    }

    if (!mounted) return;
    setState(() {
      progress = -1;
      userState = value;
    });
  }
}
