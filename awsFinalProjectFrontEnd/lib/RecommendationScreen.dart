import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:makefriend/cards.dart';
import 'package:makefriend/matches.dart';
import 'package:makefriend/profiles.dart';
import 'package:makefriend/global.dart' as global;
import 'package:http/http.dart' as http;

class RecommendationScreen extends StatefulWidget {
  @override
  createState() => RecommendationScreenState();
}

class RecommendationScreenState extends State<RecommendationScreen> {
  List<String> arguments;
  List<Profile> recommendations = new List<Profile>();
  List<List<String>> friendList = new List<List<String>>();
  MatchEngine matchEngine;
  @override
  void initState() {
    super.initState();
    List<Profile> assignList = new List<Profile>();
    _getRecommendationRequest().then((result) {
      //result is List<List<String>>
      result.forEach((internList) {
        Profile profile = new Profile(
            photos: internList[3],
            name: internList[1] + " " + internList[2],
            uid: internList[0]);
        assignList.add(profile);
      });

      setState(() {
        recommendations = assignList;
        matchEngine = MatchEngine(
            matches: recommendations.map((Profile profile) {
          return Match(profile: profile);
        }).toList());
      });
    });

    _getFriendList().then((result) {
      setState(() {
        friendList = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context).settings.arguments;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                      icon: Icon(
                    Icons.collections,
                    color: Colors.blue,
                  )),
                  Tab(
                      icon: Icon(
                    Icons.face,
                    color: Colors.blue,
                  )),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  textColor: Colors.blue,
                  child: Text("Logout"),
                  onPressed: onPressWrapper(() async {
                    await Cognito.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }),
                )
              ],
              title: Text(
                'Recommendation Page',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            body: TabBarView(children: <Widget>[
              ListView(
                children: <Widget>[
                  Container(
                      width: 400,
                      height: 600,
                      alignment: Alignment.topCenter,
                      child: recommendations.isEmpty == true
                          ? Container(
                              child: CircularProgressIndicator(),
                            )
                          : CardStack(matchEngine: matchEngine)),
                  _buildBottomBar(),
                ],
              ),
              Stack(
                children: <Widget>[
                  friendList.isEmpty
                      ? Container(
                          child: CircularProgressIndicator(),
                        )
                      : ListView(
                          children: ListTile.divideTiles(
                              context: context,
                              tiles: friendList.map((item) {
                                return ListTile(
                                  title: Text(item[1] + " " + item[2]),
                                  leading: Image(
                                    image: NetworkImage(item[3]),
                                  ),
                                );
                              })).toList(),
                        ),
                  Container(
                    child: FloatingActionButton(
                      child: Icon(Icons.refresh),
                      onPressed: () {
                        _getFriendList().then((result) {
                          setState(() {
                            friendList = result;
                          });
                        });
                      },
                    ),
                    alignment: Alignment.bottomRight,
                    margin: EdgeInsets.fromLTRB(0, 0, 30, 30),
                  ),
                ],
              )
            ])));
  }

  Future<List<List<String>>> _getFriendList() async {
    String url =
        "https://6fhwe9t0m4.execute-api.us-east-1.amazonaws.com/Stage1/user/getUserFriendList/" +
            global.uid;
    var response = await http.get(url);
    List<List<String>> result = new List<List<String>>();
    if (response.statusCode == 504) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Timeout"),
            content: Text(
                "It seems like Neptune process too long and api gateway timeout. Please try it again"),
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
      return result;
    }
    List<dynamic> tmp = jsonDecode(response.body)["body"];

    tmp.forEach((item) {
      List<String> castItem = new List<String>.from(item);
      result.add(castItem);
    });
    return result;
  }

  Future<List<List<String>>> _getRecommendationRequest() async {
    String url =
        "https://6fhwe9t0m4.execute-api.us-east-1.amazonaws.com/Stage1/user/getUserRecommendations/" +
            global.uid;

    var response = await http.get(url, headers: {"Authorization" : global.access_token});
    List<List<String>> result = new List<List<String>>();
    if (response.statusCode == 504) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Timeout"),
            content: Text(
                "It seems like Neptune process too long and api gateway timeout. Please try it again"),
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
      return result;
    }
    List<dynamic> tmp = jsonDecode(response.body)["body"];
    tmp.forEach((item) {
      List<String> castItem = new List<String>.from(item);
      result.add(castItem);
    });
    return result;
  }

  Future _like() async {
    String url =
        "https://6fhwe9t0m4.execute-api.us-east-1.amazonaws.com/Stage1/user/like/" +
            global.uid +
            "/" +
            matchEngine.currentMatch.profile.uid;

    var response = await http.get(url);
    return;
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new RoundIconButton.large(
                icon: Icons.refresh,
                iconColor: Colors.orange,
                onPressed: () {
                  List<Profile> assignList = new List<Profile>();
                  _getRecommendationRequest().then((result) {
                    //result is List<List<String>>
                    result.forEach((internList) {
                      Profile profile = new Profile(
                          photos: internList[3],
                          name: internList[1] + " " + internList[2],
                          uid: internList[0]);
                      assignList.add(profile);
                    });
                    setState(() {
                      recommendations = assignList;
                      matchEngine = MatchEngine(
                          matches: recommendations.map((Profile profile) {
                        return Match(profile: profile);
                      }).toList());
                    });
                  });
                },
              ),
              new RoundIconButton.large(
                icon: Icons.clear,
                iconColor: Colors.red,
                onPressed: () {
                  matchEngine.currentMatch.nope();
                },
              ),
              new RoundIconButton.large(
                icon: Icons.favorite,
                iconColor: Colors.green,
                onPressed: () async {
                  matchEngine.currentMatch.like();
                  await _like();
                },
              ),
            ],
          ),
        ));
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

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton.large({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 60.0;

  RoundIconButton.small({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 50.0;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            new BoxShadow(color: const Color(0x11000000), blurRadius: 10.0),
          ]),
      child: new RawMaterialButton(
        shape: new CircleBorder(),
        elevation: 0.0,
        child: new Icon(
          icon,
          color: iconColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
