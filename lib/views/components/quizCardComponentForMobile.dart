import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/views/components/mobileLoginPage.dart';
import '../QuizView.dart';
import '../mobileMainPage.dart';
import 'package:iter/services/databaseService.dart';

class QuizCardComponentForMobile extends StatefulWidget {
  final Quiz quiz;
  final bool quizJoined;
  final MobileMainPageState parent;

  QuizCardComponentForMobile({this.quiz, this.quizJoined, this.parent});

  @override
  _QuizCardComponentForMobileState createState() => _QuizCardComponentForMobileState();
}


class _QuizCardComponentForMobileState extends State<QuizCardComponentForMobile> {
  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        child: Banner(
          location: BannerLocation.topStart,
          color: averageQuizDifficulty().color,
          message: "Quiz ${averageQuizDifficulty().name}",
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              image: DecorationImage(
                  image: AssetImage("assets/images/back/${widget.quiz.imagePath}.jpg"),
                  fit: BoxFit.cover),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Text(widget.quiz.questions.length == 1
                        ? "${widget.quiz.questions.length} Question"
                        : "${widget.quiz.questions.length} Questions",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ],
                ),
                Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height / 20,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 3,
                    decoration: BoxDecoration(
                        color: averageQuizDifficulty().color, borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                        child: Text(widget.quiz.quizName, maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold, fontSize: 15
                            )
                        )
                    )
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 25,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 4,
                      decoration: BoxDecoration(
                          color: !widget.quizJoined ? Colors.blue : Colors.red,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: FlatButton(
                          onPressed: () =>
                              widget.parent.updateQuizChoice(widget.quiz.id),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !widget.quizJoined ? Text("Rejoindre") : Text("Quitter")
                            ],
                          )
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Quiz')
                            .doc(widget.quiz.id)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          var userDocument = snapshot.data;
                          if (userDocument["waitingPlayers"].length == 2 &&
                              widget.quizJoined &&
                              snapshot.connectionState == ConnectionState.active) {
                            if (MobileLoginPageState.status == 1){
                              List<String> playersId = List.castFrom(userDocument['waitingPlayers'] as List ?? []);
                              adminStartQuiz(playersId);
                            } else {
                              if(userDocument["hasJoined"]){
                                SchedulerBinding.instance.addPostFrameCallback((_) {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              QuizView(quiz: widget.quiz)
                                      )
                                  );
                                });
                              }
                            }
                          }
                          List<String> playersId = List.castFrom(
                              userDocument['waitingPlayers'] as List ?? []);
                          return Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: SizedBox(
                                      width : 30,
                                      height : 30,
                                      child: Image.asset(playersId == null || playersId.length == 0 ? "assets/images/profil.jpg" : "assets/images/${playersId[0]}.jpg"))),
                              Text(" et ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: SizedBox(
                                    width : 30,
                                    height : 30,
                                    child: Image.asset(playersId == null || playersId.length < 2 ? "assets/images/profil.jpg" : "assets/images/${playersId[1]}.jpg")),
                              )
                            ],
                          );
                        }
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void adminStartQuiz(List<String> playersId) async {
    databaseService.createGameAndStat(widget.quiz.id, playersId, widget.quiz.questions).then( (value) {
      databaseService.setHasJoined(widget.quiz.id, true);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    QuizView(quiz: widget.quiz)
            )
        );
      });
    });
  }

  Difficulty averageQuizDifficulty() {
    double average = 0;
    for (Question question in widget.quiz.questions) {
      average += question.difficulty.index;
    }
    average = average / widget.quiz.questions.length;

    if (average < 1) {
      return Difficulty.EASY;
    }
    if (average >= 1 && average < 2) {
      return Difficulty.MODERATE;
    }
    if (average >= 2 && average < 3) {
      return Difficulty.DIFFICULT;
    }
    if (average >= 3) {
      return Difficulty.INSANE;
    }
    else {
      return Difficulty.EASY;
    }
  }
}
