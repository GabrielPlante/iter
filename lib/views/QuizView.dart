import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';

class QuizView extends StatefulWidget {
  QuizView({this.quiz});
  final Quiz quiz;
  @override
  _QuizView createState() => _QuizView(quiz: quiz);
}

class _QuizView extends State<QuizView> {
  Quiz quiz;
  _QuizView({
    @required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      Center(
          child: Text(quiz.quizName,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
      SizedBox(height: 25),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                height: 300,
                minWidth: 300,
                disabledColor: Colors.grey,
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Text("Réponse A", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 25),
              FlatButton(
                height: 300,
                minWidth: 300,
                disabledColor: Colors.grey,
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Text("Réponse B", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                height: 300,
                minWidth: 300,
                disabledColor: Colors.grey,
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Text("Réponse C", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 25),
              FlatButton(
                height: 300,
                minWidth: 300,
                disabledColor: Colors.grey,
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Text("Réponse D", style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      )
    ]));
  }
}
