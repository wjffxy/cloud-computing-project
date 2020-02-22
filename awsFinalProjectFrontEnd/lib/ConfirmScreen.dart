import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:makefriend/SignUpScreen.dart';
import 'package:http/http.dart' as http;
import 'package:makefriend/global.dart' as global;
import 'package:pin_code_text_field/pin_code_text_field.dart';

class ConfirmScreen extends StatefulWidget {
  @override
  createState() => ConfirmScreenState();
}

class ConfirmScreenState extends State<ConfirmScreen> {
  PassInArgument args;
  double progress;
  List<String> arguments;
  UserState userState;
  var returnValue;
  final otpController = TextEditingController();
  String thisText = "";
  int pinLength = 6;

  bool hasError = false;
  String errorMessage;

  @override
  void initState() {
    super.initState();
    Cognito.registerCallback((value) {
      if (!mounted) return;
      setState(() {
        userState = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Cognito.registerCallback(null);
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "ConfirmPage",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: buildBody(),
    ), 
    onWillPop: () async {
      await Cognito.signOut();
      return true;
    },);
  }

  Widget buildBody() {
    return Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Text(thisText, style: Theme.of(context).textTheme.title),
              ),
              PinCodeTextField(
                autofocus: false,
                controller: otpController,
                hideCharacter: false,
                highlight: true,
                highlightColor: Colors.blue,
                defaultBorderColor: Colors.black,
                hasTextBorderColor: Colors.green,
                maxLength: pinLength,
                hasError: hasError,
                maskCharacter: "😎",
                onTextChanged: (text) {
                  setState(() {
                    hasError = false;
                  });
                },
                onDone: (text) {
                  print("DONE $text");
                },
                wrapAlignment: WrapAlignment.start,
                pinBoxWidth: 60,
                pinBoxHeight: 60,
                pinBoxOuterPadding: EdgeInsets.all(5),
                pinBoxDecoration:
                    ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                pinTextStyle: TextStyle(fontSize: 20.0),
                pinTextAnimatedSwitcherTransition:
                    ProvidedPinBoxTextAnimation.scalingTransition,
                pinTextAnimatedSwitcherDuration: Duration(milliseconds: 150),
              ),
              RaisedButton(
                child: Text("continue"),
                onPressed: onPressWrapper(() async {
                  UserState state = await Cognito.getCurrentUserState();
                  if (arguments[1] == "signUp") {
                    try {
                      var otpResponse = await Cognito.confirmSignUp(
                          arguments[0], otpController.text);
                      await _makeRegisterRequest(arguments[0]);
                      return Navigator.popUntil(
                          context, (route) => route.isFirst);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Not Authorized"),
                            content: Text(
                                e.message.substring(0, e.message.indexOf("("))),
                            actions: [
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    try {
                      var signinResult =
                          await Cognito.confirmSignIn(otpController.text);
                      var accessToken = await Cognito.getTokens();
                      var uid = await _makeLoginRequst(arguments[0]);
                      global.uid = uid;
                      global.access_token =  accessToken.accessToken;
                      return Navigator.pushNamedAndRemoveUntil(
                          context, '/recommendation', (route) => false,
                          arguments: [uid]);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Not Authorized"),
                            content: Text(
                                e.message.substring(0, e.message.indexOf("("))),
                            actions: [
                              FlatButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                }),
              )
            ],
          ),
        ));
  }

  Future<String> _makeLoginRequst(String name) async {
    String url =
        "https://6fhwe9t0m4.execute-api.us-east-1.amazonaws.com/Stage1/user/login/" +
            name;
    var response = await http.get(url);
    String result = jsonDecode(response.body.toString())["body"];
    return result;
  }

  Future _makeRegisterRequest(String name) async {
    String url =
        "https://6fhwe9t0m4.execute-api.us-east-1.amazonaws.com/Stage1/user/register/";
    Map<String, String> header = {"Content-Type": "application/json"};
    Map<String, String> body = {"userName": name};
    var response =
        await http.post(url, headers: header, body: json.encode(body));
    return;
  }

  onPressWrapper(fn) {
    wrapper() async {
      String value;
      try {
        value = (await fn()).toString();
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
      } finally {}
    }

    return wrapper;
  }
}
