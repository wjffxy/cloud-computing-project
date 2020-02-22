import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

class SignInScreen extends StatefulWidget {
  @override
  createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  UserState userState;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final attrsController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmationCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
              padding: EdgeInsets.all(36.0),
              alignment: Alignment.center,
              child: buildChildren(
                <List<Widget>>[
                  [
                    SizedBox(
                      height: 155.0,
                      child: Image(
                        image: NetworkImage(
                            "https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png"),
                      ),
                    )
                  ],
                  ...textFields(),
                  signIn(),
                  signUp(),
                ],
              )),
        ));
  }

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

  onPressWrapper(fn) {
    wrapper() async {
      String value;
      try {
        value = (await fn()).toString();
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
        setState(() => value = e.toString());
      } finally {}
    }

    return wrapper;
  }

  signUp() {
    return [
      Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            child: Text("signUp"),
            onPressed: onPressWrapper(() {
              return Navigator.pushNamed(context, "/signUp");
            }),
          )),
    ];
  }

  signIn() {
    return [
      Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.blue,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            child: Text(
              "Sign In",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: onPressWrapper(() async {
              var state = await Cognito.getCurrentUserState();
              String name = usernameController.text;
              String password = passwordController.text;
              try {
                await Cognito.signIn(name, password);
                return Navigator.pushNamed(context, "/confirm",
                    arguments: [usernameController.text, "signIn"]);
              } on NotAuthorizedException catch (e) {
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
            }),
          )),
    ];
  }

  Widget buildChildren(List<List<Widget>> children) {
    List<Widget> c = children
        .map((item) => Center(child: (Column(children: item))))
        .toList();
    return ListView.separated(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: c[index],
        );
      },
      separatorBuilder: (context, index) {
        return Container();
      },
    );
  }

  textFields() {
    return [
      [
        TextField(
          obscureText: false,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          decoration: InputDecoration(
              hintText: 'User Name',
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
          controller: usernameController,
        ),
        SizedBox(
          height: 45,
        ),
        TextField(
          obscureText: true,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Password",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
          controller: passwordController,
        ),
      ],
    ];
  }
}
