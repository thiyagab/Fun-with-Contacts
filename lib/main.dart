import 'package:flutter/material.dart';
import './cards.dart';
import './matches.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColorBrightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
      leading: new IconButton(
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
        new IconButton(
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

  //TODO Optimize

  void testMethod() {
    var profiles = Set();
    Profile profile1 = Profile(id: "200743");
    Profile profile2 = Profile(id: "200744");
    Profile profile3 = Profile(id: "200745");

    profiles.add(profile1);
    profiles.add(profile2);
    profiles.add(profile3);

    Profile profile4 = Profile(id: "200743");
    print(profile1 == profile4);
    profiles.remove(profile4);
  }

  String appendString(Item item) {
    return item.label + " " + item.value;
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

                  IconButton.small(
                    icon:Icons.refresh,
                    iconColor: Colors.orange,
                    text: "Refresh",
                    onPressed: refreshPressed,
                  ),

                new IconButton.small(
                  icon:Icons.clear,
                  iconColor: Colors.red,
                text:ContactsUtil.totalDislikes.toString(),
                    onPressed: ()=>{matchEngine.currentMatch.nope()}
              ),
                new IconButton.small(
                  icon:Icons.star,
                  iconColor: Colors.blue,
                text:ContactsUtil.totalSuperLikes.toString(),
                    onPressed: ()=>{matchEngine.currentMatch.superLike()}
              ),

                new IconButton.small(
                  icon:Icons.favorite,
                  iconColor: Colors.green,
                text:ContactsUtil.totalLikes.toString(),
                    onPressed: ()=>{matchEngine.currentMatch.like()}
              ),

                new IconButton.small(
                  icon:Icons.share,
                  iconColor: Colors.purple,
                text:"Share"
              ),
            ],
          ),
        ));
  }

//  @override
//  Widget build1(BuildContext context) {
//    return FutureBuilder(
//        future: loadContacts(),
//        builder: (context, snapshot) => Scaffold(
//              appBar: _buildAppBar(),
//              body: snapshot.hasData && (snapshot.data as List).length > 0
//                  ? new CardStack(matchEngine: _buildMatchEngine(snapshot.data))
//                  : Center(child: Text("Loading..")),
//              bottomNavigationBar: _buildBottomBar(),
//            ));
//  }

  @override
  Widget build(BuildContext context) {
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
    loadContacts();
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

class IconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onPressed;
  final String text;

  IconButton.large({
    this.icon,
    this.iconColor,
    this.onPressed,
    this.text
  }) : size = 60.0;

  IconButton.small({
    this.icon,
    this.iconColor,
    this.onPressed,
    this.text
  }) : size = 40.0;

  IconButton({
    this.icon,
    this.iconColor,
    this.size,
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return
    Container(
        padding: EdgeInsets.all(5.0),
        child: InkWell(

      onTap: this.onPressed,
      child:new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      new Icon(
        this.icon,
        color: this.iconColor,
        size: size,
      ),
      if(null!=text)Text(text)
    ])));
  }
}

//Column(children:
//[new RoundIconButton.large(
//icon: Icons.clear,
//iconColor: Colors.red,
//onPressed: () {
//matchEngine.currentMatch.nope();
//},
//
//
//),
//new Text(ContactsUtil.totalDislikes.toString())]),
//Column(children:
//[new RoundIconButton.small(
//icon: Icons.star,
//iconColor: Colors.blue,
//onPressed: () {
//matchEngine.currentMatch.superLike();
//},
//),
//new Text(ContactsUtil.totalSuperLikes.toString())]),
//
//Column(children:
//[new RoundIconButton.large(
//icon: Icons.favorite,
//iconColor: Colors.green,
//onPressed: () {
//matchEngine.currentMatch.like();
//},
//),
//new Text(ContactsUtil.totalLikes.toString())]),
