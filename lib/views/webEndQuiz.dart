import 'package:flutter/material.dart';
import 'package:iter/models/game.dart';

class WebEndQuiz extends StatelessWidget {
  Game currentGame;

  WebEndQuiz({this.currentGame});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("You are a wizard Harry"),
    );
  }
}
