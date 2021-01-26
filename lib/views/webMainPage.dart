import 'package:flutter/material.dart';

class WebMainPage extends StatefulWidget {
  @override
  _WebMainPageState createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(" Vous êtes sur la version web !"),
      ),
    );
  }
}
