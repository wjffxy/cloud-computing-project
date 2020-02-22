import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

class SignUpScreen extends StatefulWidget {
  @override
  createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  UserState userState;
  double progress;
  var returnValue;

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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Sign Up', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: buildChildren(
              <List<Widget>>[
                ...textFields(),
                [],
                submit(),
              ],
            )));
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
        SizedBox(height: 45.0),
        TextField(
          obscureText: false,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          decoration: InputDecoration(
              hintText: 'User Name',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
          controller: userNameController,
        ),
        SizedBox(height: 45.0),
        TextField(
          obscureText: true,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          decoration: InputDecoration(
              hintText: 'Password',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
          controller: passwordController,
        ),
        SizedBox(height: 45.0),
        TextField(
          obscureText: false,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          decoration: InputDecoration(
              hintText: 'Email',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
          controller: emailController,
        ),
        SizedBox(height: 45.0),
        TextField(
          controller: phoneController,
          obscureText: false,
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          decoration: InputDecoration(
              hintText: 'Phone Number',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0))),
        )
      ],
    ];
  }

  submit() {
    return [
      Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.blue,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            child: Text("submit"),
            onPressed: onPressWrapper(() async {
              var state = await Cognito.getCurrentUserState();
              String name = userNameController.text;
              String password = passwordController.text;
              String email = emailController.text;
              String phone = phoneController.text;
              PassInArgument args =
                  PassInArgument(name, password, email, phone);
              try {
                await Cognito.signUp(name, password, args.attributes);
                return Navigator.pushNamed(context, "/confirm",
                    arguments: [name, "signUp"]);
              } on UsernameExistsException catch(e){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("User Name exists"),
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
              } on InvalidParameterException catch(e){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Invalid parameter"),
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
}

class PassInArgument {
  String name;
  String password;
  Map<String, String> attributes = Map<String, String>();

  PassInArgument(String name, String password, String email, String phone) {
    this.name = name;
    this.password = password;
    attributes.putIfAbsent("email", () => email);
    attributes.putIfAbsent("phone_number", () => phone);
  }
}
