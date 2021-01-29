import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';

class QuizView extends StatefulWidget {
  final Quiz quiz;

  QuizView({this.quiz});

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  Quiz quiz;

  @override
  void initState() {
    quiz = widget.quiz;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(quiz.quizName)),
      body: Container(
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
                      onPressed: () {},
                      height: 300,
                      minWidth: 300,
                      disabledColor: Colors.grey,
                      shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                      child:
                        Text("Réponse A", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 25),
                    FlatButton(
                      onPressed: () {},
                      height: 300,
                      minWidth: 300,
                      disabledColor: Colors.grey,
                      shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                      child: Text("Réponse B", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      onPressed: () {},
                      height: 300,
                      minWidth: 300,
                      disabledColor: Colors.grey,
                      shape: new RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                      child:
                        Text("Réponse C", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 25),
                    FlatButton(
                      onPressed: () {},
                      height: 300,
                      minWidth: 300,
                      disabledColor: Colors.grey,
                      shape: new RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                      child:
                        Text("Réponse D", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            )]
          )
        ),
      );
  }
}
