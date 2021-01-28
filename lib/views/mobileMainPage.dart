import 'package:flutter/material.dart';
import 'package:iter/views/QuizView.dart';

class MobileMainPage extends StatefulWidget {
  @override
  _MobileMainPageState createState() => _MobileMainPageState();
}

class _MobileMainPageState extends State<MobileMainPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: QuizView()
      ),
    );
  }
}
