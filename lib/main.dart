import 'package:flutter/material.dart';
import './cards.dart';
import './matches.dart';
import './widgets/iconbutton.dart';
import 'package:tinder/data/profiles.dart';
import 'package:contacts_service/contacts_service.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';

import 'data/contactsdb.dart';
import 'data/contactsutil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fun with contacts',
      theme: ThemeData(
        primaryColorBrightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Profile>> _profiles;

  void loadContacts() {
    _profiles = ContactsUtil.loadYetoSwipeContacts();
  }

  MatchEngine _buildMatchEngine(List profiles) {
    if (profiles.length > 0) {
      MatchEngine newMatchEngine = new MatchEngine(
          matches: profiles.map((Object profile) {
        return Match(profile: profile);
      }).toList());
      return newMatchEngine;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _profiles,
        builder: (context, snapshot) =>
            snapshot.hasData && (snapshot.data as List).length > 0
                ? new ContactsTinderUI(
                    matchEngine: _buildMatchEngine(snapshot.data),
                    refreshPressed:this.refreshPressed)
                : Center(child: Text("Loading..")));
  }

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  void refreshPressed() {
    ContactsUtil.deleteAllData();
    loadContacts();
    setState(() {

    });
//    matchEngine.notifyListeners();
//    matchEngine=null;
  }
}

class ContactsTinderUI extends StatefulWidget {
  ContactsTinderUI({Key key, this.matchEngine,this.refreshPressed}) : super(key: key);

  final MatchEngine matchEngine;
  final VoidCallback refreshPressed;


  @override
  _ContactsTinderUIState createState() => _ContactsTinderUIState();
}

class _ContactsTinderUIState extends State<ContactsTinderUI> {
  @override
  void initState() {
    super.initState();
    if (widget.matchEngine != null) {
      widget.matchEngine.addListener(onSwipeComplete);
    }
  }

  @override
  void didUpdateWidget(ContactsTinderUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget!=null && oldWidget.matchEngine!=null)
      oldWidget.matchEngine.removeListener(onSwipeComplete);
    widget.matchEngine.addListener(onSwipeComplete);
  }



  void onSwipeComplete() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: widget.matchEngine != null
          ? new CardStack(matchEngine: widget.matchEngine)
          : CircularProgressIndicator(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: new IconWithTextButton(
        icon: Icons.person,
        iconColor: Colors.grey,
        size: 40.0,
        onPressed: () {
          // TODO
        },
      ),
      title: new Text(_buildTitle()),
      actions: <Widget>[
        new IconWithTextButton(
          icon: Icons.chat_bubble,
          iconColor: Colors.grey,
          size: 40.0,
          onPressed: () {
            // TODO
          },
        ),
      ],
    );
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
              IconWithTextButton.small(
                icon: Icons.refresh,
                iconColor: Colors.orange,
                text: "Reset",
                onPressed: widget.refreshPressed,
              ),
              IconWithTextButton.small(
                  icon: Icons.clear,
                  iconColor: Colors.red,
                  text: ContactsUtil.totalDislikes.toString(),
                  onPressed: () => {widget.matchEngine.currentMatch.nope()}),
              IconWithTextButton.small(
                  icon: Icons.star,
                  iconColor: Colors.blue,
                  text: ContactsUtil.totalSuperLikes.toString(),
                  onPressed: () =>
                      {widget.matchEngine.currentMatch.superLike()}),
              IconWithTextButton.small(
                  icon: Icons.favorite,
                  iconColor: Colors.green,
                  text: ContactsUtil.totalLikes.toString(),
                  onPressed: () => {widget.matchEngine.currentMatch.like()}),
              IconWithTextButton.small(
                  icon: Icons.undo, iconColor: Colors.purple, text: "Undo"),
            ],
          ),
        ));
  }

  String _buildTitle() {
    if (ContactsUtil.yettoswipelength == null) {
      return "Loading..";
    } else
      return (ContactsUtil.totalContacts - ContactsUtil.yettoswipelength)
              .toString() +
          '/' +
          ContactsUtil.totalContacts.toString();
  }



}
