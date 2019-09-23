import 'package:flutter/material.dart';

class ColorfulNameDisplay extends StatelessWidget {
  ColorfulNameDisplay(this.name);

  /// The text that will be used for the icon. It is truncated to 2 characters.
  final String name;

  String getName() {
//    if (name != null && name.length != 0) {
//      if (name.length > 2) {
//        return name.substring(0, 2).toUpperCase();
//      } else
//        return name.toUpperCase();
//    }
    return name;
  }

  Color getColorByName() {
    String char = getName().substring(0, 1).toLowerCase();
    switch (char) {
      case "a":
      case "1":
      case "4":
      case "e":
      case "l":
      case "q":
      case "v":
        return Colors.blueGrey;
      case "b":
      case "g":
      case "2":
      case "6":
      case "9":
      case "i":
      case "m":
      case "r":
      case "w":
        return Colors.red;
      case "c":
      case "h":
      case "n":
      case "3":
      case "7":
      case "s":
      case "x":
        return Colors.orange;
      case "d":
      case "j":
      case "o":
      case "5":
      case "8":
      case "t":
      case "y":
        return Colors.blueAccent;
    }
    return Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(
          color: getColorByName(),
          borderRadius: new BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Text(
            getName(),
            style: TextStyle(

                fontWeight: FontWeight.w600, color: Colors.white, fontSize: 28),
          ),
        ));
  }
}