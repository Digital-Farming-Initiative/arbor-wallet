import 'package:flutter/material.dart';

class NavigationUtils{

  static push(BuildContext context,Widget page){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  static pushReplacement(BuildContext context,Widget page){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => page,
      ),
    );
  }
}