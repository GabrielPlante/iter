import'package:flutter/material.dart';
import 'package:iter/models/question.dart';
import 'package:iter/views/QuizView.dart';

class Test extends StatelessWidget {
  final Question nextQuestion;
  final QuizViewState parent;

  Test({this.nextQuestion, this.parent});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        child: Banner(
          location: BannerLocation.topStart,
          color: nextQuestion.difficulty.color,
          message: nextQuestion.difficulty.name,
          child: GestureDetector(
            onTap: () => skip(),
            child: Container(
              width: MediaQuery.of(context).size.width / 1.3,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text("Prochaine question :")),
                  SizedBox(height: 5,),
                  Center(child: Text(nextQuestion.questionName, style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(height: 5,),
                  Center(child: Text("appuyer pour sauter"),)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void skip() {
    parent.skipNextQuestion( parent.nbrOfQuestionSkipped + 1);
    final snackBar = SnackBar(
        content: Text("Question sautée"),
        backgroundColor: Colors.lightBlue
    );
    ScaffoldMessenger.of(parent.context)
        .showSnackBar(snackBar);
  }
}
