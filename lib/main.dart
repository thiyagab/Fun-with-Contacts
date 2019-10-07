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
      home: MyHomePage(title: 'Fun with contacts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MatchEngine matchEngine;

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: new IconWithTextButton(
        icon:
          Icons.person,
          iconColor: Colors.grey,
          size: 40.0,

        onPressed: () {
          // TODO
        },
      ),
      title: new Text(_buildTitle()),
      actions: <Widget>[
        new IconWithTextButton(
          icon:
            Icons.chat_bubble,
            iconColor: Colors.grey,
            size: 40.0,
          onPressed: () {
            // TODO
          },
        ),
      ],
    );
  }

  void loadContacts() async{
    List profiles=await ContactsUtil.loadYetoSwipeContacts();
    _buildMatchEngine(profiles);

  }

  MatchEngine _buildMatchEngine(List profiles) {
    if (profiles.length > 0) {
      MatchEngine newMatchEngine = new MatchEngine(
          matches: profiles.map((Object profile) {
        return Match(profile: profile);
      }).toList());
      newMatchEngine.addListener(onSwipeComplete);
      matchEngine=newMatchEngine;
      return newMatchEngine;
    }
    return null;
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
                    icon:Icons.refresh,
                    iconColor: Colors.orange,
                    text: "Refresh",
                    onPressed: refreshPressed,
                  ),

                 IconWithTextButton.small(
                  icon:Icons.clear,
                  iconColor: Colors.red,
                text:ContactsUtil.totalDislikes.toString(),
                    onPressed: ()=>{matchEngine.currentMatch.nope()}
              ),
                 IconWithTextButton.small(
                  icon:Icons.star,
                  iconColor: Colors.blue,
                text:ContactsUtil.totalSuperLikes.toString(),
                    onPressed: ()=>{matchEngine.currentMatch.superLike()}
              ),

                 IconWithTextButton.small(
                  icon:Icons.favorite,
                  iconColor: Colors.green,
                text:ContactsUtil.totalLikes.toString(),
                    onPressed: ()=>{matchEngine.currentMatch.like()}
              ),

                 IconWithTextButton.small(
                  icon:Icons.share,
                  iconColor: Colors.purple,
                text:"Share"
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ContactsUtil.loadYetoSwipeContacts(),
        builder: (context, snapshot) => Scaffold(
              appBar: _buildAppBar(),
              body: snapshot.hasData && (snapshot.data as List).length > 0
                  ? new CardStack(matchEngine: _buildMatchEngine(snapshot.data))
                  : Center(child: Text("Loading..")),
              bottomNavigationBar: _buildBottomBar(),
            ));
  }

  @override
  Widget build1(BuildContext context) {
    return Scaffold(
          appBar: _buildAppBar(),
          body: matchEngine!=null
              ? new CardStack(matchEngine: this.matchEngine)
              : Center(child: Text("Loading..")),
          bottomNavigationBar: _buildBottomBar(),
        );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    loadContacts();
  }

  void openContact(String contactId) async {
//    if (platform.isAndroid) {
    final AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: 'content://com.android.contacts/contacts/' +
          contactId, // replace com.example.app with your applicationId
    );
    await intent.launch();
//    }
  }
  //TODO DO a proper state management, this code refreshes the whole UI, and refreshes contact again
  void onSwipeComplete() {
    setState(() {});
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

  void refreshPressed() {
    ContactsUtil.deleteAllData();
    loadContacts();
    matchEngine.notifyListeners();
//    matchEngine=null;
  }
}

