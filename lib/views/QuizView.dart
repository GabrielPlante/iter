import 'package:flutter/cupertino.dart';
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
  bool finishQuestion = false;
  int index = 0;
  List<bool> isSelectedItem = [false, false, false, false];

  Widget initQuizComponents(int index) {
    String displayAvancement = " Question ${index + 1} / ${widget.quiz.questions.length} ";
    if(index < questions.length) return QuizComponent(question: questions[index], parent: this, isSelectedItem: isSelectedItem, displayAvancement: displayAvancement);
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
      appBar: AppBar(title: Text(widget.quiz.quizName),
        actions: [
          Visibility(
              visible: finishQuestion,
              child: Container(
                color: Colors.green,
                child: FlatButton(
                  onPressed: () {
                    setState( () {
                      index++;
                      finishQuestion = false;
                      isSelectedItem = [false, false, false, false];
                    });
                  },
                    child: Row(
                        children: [
                          Text(" Question suivante ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                          Icon(Icons.navigate_next)
                      ]
                  ),
                ),
              )
          ),
        ],
      ),
      body: initQuizComponents(index),
      );
  }

  void nextQuestion() {
    setState(() {
      finishQuestion = true;
    });
  }

  void setSelected(int position) {
    setState(() {
      isSelectedItem[position] = true;
    });
  }
}


class QuizComponent extends StatelessWidget {
  final Question question;
  final QuizViewState parent;
  final List<bool> isSelectedItem;
  final String displayAvancement;

  QuizComponent({Key key, this.question, this.parent, this.isSelectedItem, this.displayAvancement }) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Center(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Text(  displayAvancement + " : ${question.questionName}",
                    style: TextStyle(fontSize: 200, fontWeight: FontWeight.bold)),
              )),
          SizedBox(height: MediaQuery.of(context).size.height / 8),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton( onPressed: () {
                    selectedAndVerifyAnswer(question.answers[0],0);
                  },
                    height: MediaQuery.of(context).size.height / 4,
                    minWidth: MediaQuery.of(context).size.width / 3,
                    color: isSelectedItem[0] && question.correctAnswer == question.answers[0] ? Colors.green : isSelectedItem[0] ? Colors.red : Theme.of(context).backgroundColor,
                    disabledColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                    ),
                    hoverColor:isSelectedItem[0] && question.correctAnswer == question.answers[0] ? Colors.green : isSelectedItem[0] ? Colors.red : Colors.blue,
                    child:
                    Text(question.answers[0], style: TextStyle(fontSize: 50)),
                  ),
                  SizedBox(width: 25),
                  FlatButton(
                    onPressed: () {
                      selectedAndVerifyAnswer(question.answers[1],1);
                    },
                    height: MediaQuery.of(context).size.height / 4,
                    minWidth: MediaQuery.of(context).size.width / 3,
                    color: isSelectedItem[1] && question.correctAnswer == question.answers[1] ? Colors.green : isSelectedItem[1] ? Colors.red : Theme.of(context).backgroundColor,
                    disabledColor: Colors.grey,
                    hoverColor:isSelectedItem[1] && question.correctAnswer == question.answers[1] ? Colors.green : isSelectedItem[1] ? Colors.red : Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(question.answers[1], style: TextStyle(fontSize: 50)),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton(
                    onPressed: () {
                      selectedAndVerifyAnswer(question.answers[3],2);
                    },
                    height: MediaQuery.of(context).size.height / 4,
                    minWidth: MediaQuery.of(context).size.width / 3,
                    color: isSelectedItem[2] && question.correctAnswer == question.answers[3] ? Colors.green : isSelectedItem[2] ? Colors.red : Theme.of(context).backgroundColor,
                    disabledColor: Colors.grey,
                    hoverColor: isSelectedItem[2] && question.correctAnswer == question.answers[3] ? Colors.green : isSelectedItem[2] ? Colors.red : Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child:
                    Text(question.answers[3], style: TextStyle(fontSize: 50)),
                  ),
                  SizedBox(width: 25),
                  FlatButton(
                    onPressed: () {
                      selectedAndVerifyAnswer(question.answers[2],3);
                    },
                    height: MediaQuery.of(context).size.height / 4,
                    minWidth: MediaQuery.of(context).size.width / 3,
                    color: isSelectedItem[3] && question.correctAnswer == question.answers[2] ? Colors.green : isSelectedItem[3] ? Colors.red : Theme.of(context).backgroundColor,
                    disabledColor: Colors.grey,
                    hoverColor: isSelectedItem[3] && question.correctAnswer == question.answers[2] ? Colors.green : isSelectedItem[3] ? Colors.red : Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child:
                    Text(question.answers[2], style: TextStyle(fontSize: 50)),
                  ),
                ],
              )
            ],
          )]
        )
    );
  }


  bool selectedAndVerifyAnswer(String answer, int position) {
    parent.setSelected(position);
    if(answer == question.correctAnswer) {
      parent.nextQuestion();
    }
  }
}

class EndQuizComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("End of the quiz"));
  }
}


