import 'package:flutter/material.dart';
import 'package:iter/models/game.dart';
import 'package:iter/views/components/LogoDisplayer.dart';

class WebEndQuiz extends StatelessWidget {
  final Game currentGame;

  WebEndQuiz({this.currentGame});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/city_wallpaper.jpg"),
                fit: BoxFit.cover
            )
        ),
        child: Center(
          child: Column(
            children: [
              Text("Fin du quiz, merci d'avoir participé !", ),
              SizedBox(height: 15.0),
              LogoDisplayer(),
            ],
          ),
        ),
      ),
    );
  }
}
