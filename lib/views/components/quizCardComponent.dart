import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/views/QuizView.dart';
import 'package:iter/views/webMainPage.dart';

class QuizCardComponent extends StatefulWidget {
  final Quiz quiz;
  final bool quizJoined;
  final WebMainPageState parent;

  QuizCardComponent({this.quiz, this.quizJoined, this.parent});

  @override
  _QuizCardComponentState createState() => _QuizCardComponentState();
}

class _QuizCardComponentState extends State<QuizCardComponent> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(widget.quiz.quizName),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Nombre de questions : ${widget.quiz.questions.length}"),
              FlatButton(
                  onPressed: () => widget.parent.updateQuizChoice(widget.quiz.id),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !widget.quizJoined ? Icon(Icons.add) : Icon(Icons.keyboard_return),
                      !widget.quizJoined ? Text("Rejoindre") : Text("Quitter")
                    ],
                  )
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Difficulté : facile"),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('Quiz').doc(widget.quiz.id).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading");
                    }
                    var userDocument = snapshot.data;
                    if(userDocument["numberOfPlayers"] >= 2 && widget.quizJoined){
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizView(quiz: widget.quiz)));
                      });
                    }
                    return Text("Nombre de joueurs : ${userDocument["numberOfPlayers"]} / 2");
                  }
              ),
            ],
          )
        ],
      ),
    );
  }
}
