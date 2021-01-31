import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iter/models/quiz.dart';
import '../QuizView.dart';
import '../mobileMainPage.dart';

class QuizCardComponentForMobile extends StatefulWidget {
  final Quiz quiz;
  final bool quizJoined;
  final MobileMainPageState parent;

  QuizCardComponentForMobile({this.quiz, this.quizJoined, this.parent});

  @override
  _QuizCardComponentForMobileState createState() => _QuizCardComponentForMobileState();
}

class _QuizCardComponentForMobileState extends State<QuizCardComponentForMobile> {

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
                    if(userDocument["waitingPlayers"].length >= 2 && widget.quizJoined && snapshot.connectionState == ConnectionState.active){
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizView(quiz: widget.quiz)));
                      });
                    }
                    return Text("Nombre de joueurs : ${userDocument["waitingPlayers"].length} / 2");
                  }
              ),
            ],
          )
        ],
      ),
    );
  }
}
