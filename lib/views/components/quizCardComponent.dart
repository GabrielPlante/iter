import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/services/databaseService.dart';
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
  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                  disabledColor: Colors.green,
                  child: Text("Quizz facile",
                      style: TextStyle(color: Colors.white))),
              SizedBox(height: 10),
              /*FlatButton(
                disabledColor: Colors.blue,
                child: Text("${widget.quiz.questions.length} questions", style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
              )*/
              Text("${widget.quiz.questions.length} Questions", style: TextStyle(color: Colors.white)),
            ],
          ),
          FlatButton(
            height: 50,
            minWidth: 250,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            disabledColor: Colors.grey,
              child: Text(widget.quiz.quizName, style: TextStyle(color: Colors.white))
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                  onPressed: () =>
                      widget.parent.updateQuizChoice(widget.quiz.id),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !widget.quizJoined
                          ? Icon(Icons.add)
                          : Icon(Icons.keyboard_return),
                      !widget.quizJoined ? Text("Rejoindre") : Text("Quitter")
                    ],
                  )),
              SizedBox(height: 10),
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Quiz')
                      .doc(widget.quiz.id)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Loading");
                    }
                    var userDocument = snapshot.data;
                    if (userDocument["waitingPlayers"].length >= 2 &&
                        widget.quizJoined &&
                        snapshot.connectionState == ConnectionState.active) {
                      List<String> playersId = List.castFrom(
                          userDocument['waitingPlayers'] as List ?? []);
                      adminStartQuiz(playersId);
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    QuizView(quiz: widget.quiz)));
                      });
                    }
                    return Text(
                        "${userDocument["waitingPlayers"].length} / 2 Joueurs");
                  }),
            ],
          )
        ],
      ),
    ));
  }

  void adminStartQuiz(List<String> playersId) async {
    await databaseService.createGame(
        widget.quiz.id, playersId, widget.quiz.questions);
  }
}
