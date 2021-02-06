import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iter/main.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/services/databaseService.dart';
import 'package:iter/views/webMainPage.dart';

import 'mobileMainPage.dart';

class QuizView extends StatefulWidget {
  final Quiz quiz;

  QuizView({this.quiz});

  @override
  QuizViewState createState() => QuizViewState();
}

class QuizViewState extends State<QuizView> {
  List<Question> questions = [];
  Game currentGame;
  DatabaseService databaseService  = DatabaseService();
  bool finishQuestion = false;
  int index = 0;
  int indexOfPlayer = 0;
  List<bool> isSelectedItem = [false, false, false, false];

  Widget initQuizComponents(int index) {
    String displayAvancement = " Question ${index + 1} / ${widget.quiz.questions.length} ";
    if(index < questions.length) return QuizComponent(question: questions[index], parent: this, isSelectedItem: isSelectedItem, displayAvancement: displayAvancement);
    else return EndQuizComponent();
  }
  @override
  void initState() {
    questions = widget.quiz.questions;
    initGame();
    super.initState();
  }

  void initGame() async {
    bool isWeb = MyApp.isWebDevice;
    DateTime dateNow = DateTime.now();
    List<Game> result = await databaseService.allGame;
    for(Game game in result) {
      if(isWeb){
        if(game.playersId.contains(WebMainPage.userId) && dateNow.difference(game.dateOfGame).inMinutes <= 1 ) {
          setState(() {
            currentGame = game;
            indexOfPlayer = currentGame.playersId.indexOf(WebMainPage.userId);
          });
        }
      } else {
        if(game.playersId.contains(MobileMainPage.userId) &&  dateNow.difference(game.dateOfGame).inMinutes <= 1 ) {
          setState(() {
            currentGame = game;
            indexOfPlayer = currentGame.playersId.indexOf(MobileMainPage.userId);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(currentGame == null) return LoadingWidget();
    /// In order to verify what the actual fuck is going from the database to your models, shit happens my friend. Sometimes I just don't know what is going on so remember, print(wtf) at every line to know which one is fucking with you.
    //if(currentGame != null) verifyGameByPrintingData();
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
      body: Column( children:
      [
        SizedBox(height: MediaQuery.of(context).size.height / 20),
        initQuizComponents(index),
        SizedBox(height: MediaQuery.of(context).size.height / 15),
        StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('Game').doc(currentGame.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              DocumentSnapshot document = snapshot.data;
              currentGame = databaseService.updateGame(document);
              Map<int,bool> otherPlayersMoves = Map();
              List<bool> avancementList = currentGame.avancementByQuestionMap[widget.quiz.questions[index].id];
              for(int i = 0; i < avancementList.length; i++){
                if(i != indexOfPlayer) {
                  otherPlayersMoves[i] = avancementList[i];
                }
              }
              if(otherPlayersMoves.keys == null || otherPlayersMoves.keys.isEmpty) {
                return LoadingWidget();
              } else {
                return Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 8,
                    child:ListView.builder(
                      itemCount: otherPlayersMoves.keys.length,
                      itemBuilder: (context, indexOfDisplayer) {
                        if( otherPlayersMoves[otherPlayersMoves.keys.toList()[indexOfDisplayer]]){
                          return Center(child: Text("${currentGame.playersId[otherPlayersMoves.keys.toList()[indexOfDisplayer]]} a répondu à la question ! "));
                        } else {
                          return Center(child: Text("${currentGame.playersId[otherPlayersMoves.keys.toList()[indexOfDisplayer]]} n'a pas encore répondu à la question"));
                        }
                        },),
                  ),
                );
              }
            }
        ),
      ]),
      );
  }

  void verifyGameByPrintingData() {
    print("l'id de la game est ${currentGame.id}");
    print("l'id du quiz est ${currentGame.quizId}");
    for(String playerId in currentGame.playersId){
      print("un joueur est $playerId");
    }
    for(String questionId in currentGame.avancementByQuestionMap.keys) {
      for(int avancementIndex = 0; avancementIndex < currentGame.avancementByQuestionMap[questionId].length; avancementIndex++) {
        print("la question $questionId à pour état d'avancement ${currentGame.avancementByQuestionMap[questionId][avancementIndex]} du  joueur $avancementIndex");
      }
    }

    for(String playerId in currentGame.scoreByPlayerMap.keys) {
      print("le score de $playerId est de ${currentGame.scoreByPlayerMap[playerId]} ");
    }

    print("Partie créée le ${currentGame.dateOfGame.day} à ${currentGame.dateOfGame.hour} : ${currentGame.dateOfGame.minute}");
  }

  void nextQuestion(String currentQuestionId) async {
    currentGame.avancementByQuestionMap[currentQuestionId][indexOfPlayer] = true;
    databaseService.setQuestionFinished(currentGame.id, currentQuestionId, currentGame.avancementByQuestionMap);
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

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
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
          SizedBox(height: MediaQuery.of(context).size.height / 15),
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
                    Text(question.answers[0], style: TextStyle(fontSize: 20)),
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
                    child: Text(question.answers[1], style: TextStyle(fontSize: 20)),
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
                    Text(question.answers[3], style: TextStyle(fontSize: 20)),
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
                    Text(question.answers[2], style: TextStyle(fontSize: 20)),
                  ),
                ],
              )
            ],
          )]
        )
    );
  }


  void selectedAndVerifyAnswer(String answer, int position) {
    parent.setSelected(position);
    if(answer == question.correctAnswer) {
      parent.nextQuestion(question.id);
    }
  }
}

class EndQuizComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("End of the quiz"));
  }
}


