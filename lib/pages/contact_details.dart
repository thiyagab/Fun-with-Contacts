/*
 * Copyright 2018 Harsh Sharma
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:tinder/data/profiles.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/colorfulnamedisplay.dart';


class ContactDetails extends StatefulWidget {
  final Profile contact;

  ContactDetails({Key key, this.contact}) : super(key: key);

  @override
  createState() => new ContactDetailsPageState();
}

class ContactDetailsPageState extends State<ContactDetails> {
  final globalKey = new GlobalKey<ScaffoldState>();

//  final Profile contact;

//  ContactDetailsPageState(this.contact);

  @override
  Widget build(BuildContext context) {
    return new Card(
      key: globalKey,
      child: _contactDetails(),
      elevation: 5,
      margin: EdgeInsets.all(0),
    );
  }

  Widget _contactAvatar(){
    return new Material(
      child: new InkWell(
        child: new Image.memory(
          widget.contact.avatar,
          height: 100.0,
          width: 100.0,
          fit: BoxFit.fill,
        ),
      ),
    );
  }


  List<Widget> getContactWidget(List<String> texts,IconData icon,String type){
    var list = List<Widget>();
    for(int i=0;i<texts.length;i++){
      list.add(listTile(texts[i], i!=0?null:icon, type));
    }
    return list;
  }

  Widget _contactDetails() {
    return ListView(
      children: <Widget>[
        new SizedBox(
          child: (widget.contact.avatar!=null && widget.contact.avatar.length>0)?_contactAvatar():ColorfulNameDisplay(widget.contact.name),
          height: 150.0,
        ),
//        listTile(contact.name, Icons.account_circle, Texts.NAME),
        widget.contact.phones!=null?Column(children:getContactWidget(widget.contact.phones,Icons.phone, Texts.PHONE)):Text(""),
        widget.contact.emails!=null?Column(children:getContactWidget(widget.contact.emails,Icons.email, Texts.EMAIL)):Text(""),

      ],
    );
  }

  Widget listTile(String text, IconData icon, String tileCase) {
    return new GestureDetector(
      onTap: () {
        switch (tileCase) {
          case Texts.NAME:
            break;
          case Texts.PHONE:
            _launch("tel:" + text);
            break;
          case Texts.EMAIL:
            _launch("mailto:${text}?");
            break;
            break;
        }
      },
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(
              text,
              style: new TextStyle(
                color: Colors.blueGrey[400],
                fontSize: 20.0,
              ),
            ),
            leading: new Icon(
              icon,
              color: Colors.blue[400],
            ),
          ),
          new Container(
            height: 0.3,
            color: Colors.blueGrey[400],
          )
        ],
      ),
    );
  }

  void _launch(String launchThis) async {
    try {
      String url = launchThis;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print("Unable to launch $launchThis");
//        throw 'Could not launch $url';
      }
    } catch (e) {
      print(e.toString());
    }
  }
}