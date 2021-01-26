import 'package:flutter/material.dart';

class MobileMainPage extends StatefulWidget {
  @override
  _MobileMainPageState createState() => _MobileMainPageState();
}

class _MobileMainPageState extends State<MobileMainPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Vous êtes sur la version mobile !"),
      ),
    );
  }
}
