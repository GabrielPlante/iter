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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Fin du quiz, merci d'avoir participé !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
              SizedBox(height: 15.0),
              LogoDisplayer(),
            ],
          ),
        ),
      ),
    );
  }
}
