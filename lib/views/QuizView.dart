import 'package:flutter/material.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';

class QuizView extends StatefulWidget {
  final Quiz quiz;

  QuizView({this.quiz});

  @override
  QuizViewState createState() => QuizViewState();
}

class QuizViewState extends State<QuizView> {
  List<Question> questions = [];
  int index = 0;

  Widget initQuizComponents(int index) {
    if(index < questions.length) return QuizComponent(question: questions[index], parent: this);
    else return EndQuizComponent();
  }
  @override
  void initState() {
    questions = widget.quiz.questions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.quizName), actions: [
        Text(" Question ${index + 1} / ${widget.quiz.questions.length} ")
      ],),
      body: initQuizComponents(index),
      );
  }

  void nextQuestion() {
    setState(() {
      index++;
    });
  }
}


class QuizComponent extends StatefulWidget {
  final Question question;
  final QuizViewState parent;

  QuizComponent({this.question, this.parent});

  @override
  QuizComponentState createState() => QuizComponentState();
}

class QuizComponentState extends State<QuizComponent> {
  Question question;

  @override
  Widget build(BuildContext context) {
    question = widget.question;
    print(question.questionName);
    return Container(
        child: Column(children: [
          Center(
              child: Text("Question 1 : ${question.questionName}",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
          SizedBox(height: 25),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton( onPressed: () {
                    verifyAnswer(question.answers[0]);
                  },
                    height: 300,
                    minWidth: 300,
                    disabledColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child:
                    Text(question.answers[0], style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 25),
                  FlatButton(
                    onPressed: () {
                      verifyAnswer(question.answers[1]);
                    },
                    height: 300,
                    minWidth: 300,
                    disabledColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(question.answers[1], style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    onPressed: () {
                      verifyAnswer(question.answers[3]);
                    },
                    height: 300,
                    minWidth: 300,
                    disabledColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child:
                    Text(question.answers[3], style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 25),
                  FlatButton(
                    onPressed: () {
                      verifyAnswer(question.answers[2]);
                    },
                    height: 300,
                    minWidth: 300,
                    disabledColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child:
                    Text(question.answers[2], style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          )]
        )
    );
  }


  bool verifyAnswer(String answer) {
    if(answer == question.correctAnswer) {
      widget.parent.nextQuestion();
    }
  }
}

class EndQuizComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("End of the quiz"));
  }
}


