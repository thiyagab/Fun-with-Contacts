import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IconWithTextButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onPressed;
  final String text;

  IconWithTextButton.large({
    this.icon,
    this.iconColor,
    this.onPressed,
    this.text
  }) : size = 60.0;

  IconWithTextButton.small({
    this.icon,
    this.iconColor,
    this.onPressed,
    this.text
  }) : size = 40.0;

  IconWithTextButton({
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