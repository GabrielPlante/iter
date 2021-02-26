import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iter/main.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/user.dart';
import 'package:iter/services/databaseService.dart';
import 'package:iter/views/components/mobileLoginPage.dart';
import 'package:iter/views/components/webComponents/chooseNextQuestionPanel.dart';
import 'package:iter/views/webMainPage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'mobileMainPage.dart';

class QuizView extends StatefulWidget {
  final Quiz quiz;

  QuizView({this.quiz});

  @override
  QuizViewState createState() => QuizViewState();
}

class QuizViewState extends State<QuizView> {
  bool requestFailed = false;
  User user;
  List<Question> questions = [];
  Game currentGame;
  DatabaseService databaseService  = DatabaseService();
  bool finishQuestion = false;
  int index = 0;
  int indexOfPlayer = 0;
  List<bool> isSelectedItem = [false, false, false, false];
  Difficulty selectedDifficulty = Difficulty.EASY;
  Map<Difficulty,int> availableQuestionsNumberMap = Map();
  PanelController panelController = PanelController();
  bool playerAnsweredQuestion = false;


  Widget initQuizComponents(int index) {
    if(index < questions.length){
      String displayAvancement = " Question ${index + 1} / ${widget.quiz.questions.length} ";
      Question currentQuestion;
      for(Question q in questions){
        if(q.id == currentGame.questionsOrder[index]){
          currentQuestion = q;
        }
      }
      return QuizComponent(question: currentQuestion, parent: this, isSelectedItem: isSelectedItem, displayAvancement: displayAvancement, imagePath: widget.quiz.imagePath);
    }
    else return EndQuizComponent();
  }
  @override
  void initState() {
    questions = widget.quiz.questions;
    for(Difficulty difficulty in Difficulty.values) {
      int count = 0;
      for(Question question in questions) {
        if(difficulty == question.difficulty){
          count++;
        }
      }
      availableQuestionsNumberMap[difficulty] = count;
    }
    availableQuestionsNumberMap[questions[index].difficulty] --;
    newInitGame();
    super.initState();
  }

  void newInitGame() async {
    bool isWeb = MyApp.isWebDevice;

    if(isWeb){
      WebMainPage.user = await databaseService.updateUser(WebMainPage.user.id);
      user = WebMainPage.user;
      print(user.currentGameId);
    } else {
      MobileMainPage.user = await databaseService.updateUser(MobileMainPage.user.id);
      user = MobileMainPage.user;
      print(user.currentGameId);
    }

    Game result = await databaseService.getGameById(user.currentGameId);

    setState(() {
      currentGame = result;
      indexOfPlayer = currentGame.playersId.indexOf(user.id);
    });

  }

  @override
  Widget build(BuildContext context) {
    if(currentGame == null) {
      if(requestFailed){
        print("No Game find... Searching...");
        newInitGame();
      }
      return CircularProgressIndicator();
    }
    /// In order to verify what the actual fuck is going from the database to your models, shit happens my friend. Sometimes I just don't know what is going on so remember, print(wtf) at every line to know which one is fucking with you.
    //if(currentGame != null) verifyGameByPrintingData();
    if(index >= questions.length) {
      return EndQuizComponent();
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.quizName),
        actions: [
          Visibility(
              visible: finishQuestion && playerAnsweredQuestion,
              child: Container(
                color: index+1 != questions.length ? Colors.green : Colors.red,
                child: FlatButton(
                  onPressed: () {
                    if(index + 1 < questions.length) updateAvailableQuestionMap(questions[index+1].difficulty);
                    setState( () {
                      index++;
                      finishQuestion = false;
                      isSelectedItem = [false, false, false, false];
                      playerAnsweredQuestion = false;
                    });
                  },
                    child: Row(
                        children: [
                          Text(index+1 == questions.length ? " Fin du quiz" : " Question suivante ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                          Visibility(
                            visible: index+1 != questions.length,
                              child: Icon(Icons.navigate_next))
                      ]
                  ),
                ),
              )
          ),
        ],
      ),
      body:

      Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/back/${widget.quiz.imagePath}.jpg"), fit: BoxFit.cover)
        ),
        child: Column( children: [
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
                String questionId = currentGame.questionsOrder[index];
                List<bool> avancementList = currentGame.avancementByQuestionMap[questionId];
                for(int i = 0; i < avancementList.length; i++){
                  if(i != indexOfPlayer) {
                    otherPlayersMoves[i] = avancementList[i];
                  }
                }
                if(MobileLoginPageState.status == 2 && currentGame.jumpQuestion) jumpQuestionForPatient();
                if(otherPlayersMoves.keys == null || otherPlayersMoves.keys.isEmpty) {
                  return LoadingWidget();
                } else {
                  asyncTerminateQuestion(otherPlayersMoves.values.toList()[0]);
                  return Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 8,
                      child:ListView.builder(
                        itemCount: otherPlayersMoves.keys.length,
                        itemBuilder: (context, indexOfDisplayer) {
                          return ViewAnswerFromPlayer(playerName: currentGame.playersId[otherPlayersMoves.keys.toList()[indexOfDisplayer]],hasAswered: otherPlayersMoves[otherPlayersMoves.keys.toList()[indexOfDisplayer]], parent: this);
                          },
                      ),
                    ),
                  );
                }
              }
          ),
          MobileLoginPageState.status == 1 ?
          SlidingUpPanel(
            controller: panelController,
            minHeight: MediaQuery.of(context).size.height / 30,
            maxHeight: MediaQuery.of(context).size.height / 7.5,
            collapsed: GestureDetector(
              onTap: () => panelController.open(),
              child: Container(
                  height: MediaQuery.of(context).size.height / 30,
                  color: Theme.of(context).backgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard_arrow_up),
                      Icon(Icons.keyboard_arrow_up),
                      Icon(Icons.keyboard_arrow_up),
                      SizedBox(width: 30.0),
                      Center(child: Text("Choisir la prochaine question", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      SizedBox(width: 30.0),
                      Icon(Icons.keyboard_arrow_up),
                      Icon(Icons.keyboard_arrow_up),
                      Icon(Icons.keyboard_arrow_up),
                    ]
                  )
              ),
            ),
            panel: Column(
              children: [
                CustomCloserPanel(parent: this),
                ChooseNextQuestionPanel(availableQuestionsNumberMap: availableQuestionsNumberMap, selectedNextDifficulty: selectedDifficulty, quizViewState: this)
              ],
            )
          ) : Container(),
        ]),
      ),
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

  void changeQuestionOrder() async {
    databaseService.updateQuestionOrder(currentGame.id, currentGame.questionsOrder);
  }

  void setSelected(int position) {
    setState(() {
      isSelectedItem[position] = true;
    });
  }

  void changeSelectDifficulty(Difficulty newDifficulty) {
    setState(() {
      selectedDifficulty = newDifficulty;
    });
  }

  void closePanel() async {
    await panelController.close();
    setState(() {
      print(panelController.isPanelClosed);
    });
  }

  void updateAvailableQuestionMap(Difficulty difficultyOfQuestionAnswered) {
    if(availableQuestionsNumberMap[difficultyOfQuestionAnswered] != 0) {
      setState(() {
        availableQuestionsNumberMap[difficultyOfQuestionAnswered] --;
      });
    }

    if(availableQuestionsNumberMap[selectedDifficulty] == 0){
      for(Difficulty dif in Difficulty.values) {
        if(availableQuestionsNumberMap[dif] != 0) {
          selectedDifficulty = dif;
          break;
        }
      }
    }
  }

  void verifyForChangeIndexForDifficulty() async {
    if(questions[index+1].difficulty != selectedDifficulty) {
      for(Question q in questions.getRange(index+1, questions.length)) {
        if(q.difficulty == selectedDifficulty) {
          Question question = questions[index+1];
          int indexOfChangingQ = questions.indexOf(q);
          setState(() {
            questions[index+1] = q;
            currentGame.questionsOrder[index+1] = q.id;
            questions[indexOfChangingQ] = question;
            currentGame.questionsOrder[indexOfChangingQ] = question.id;
          });
          changeQuestionOrder();
          break;
        }
      }
    }
  }

  Future asyncTerminateQuestion(bool updateMove) async {
    if(updateMove && !playerAnsweredQuestion){
      Future.delayed(
          const Duration(seconds: 2),
              () {
            setState(() {
              playerAnsweredQuestion = true;
            });
              }
      );
    }
  }

  void cheatToNextQuestion() async {
    updateAvailableQuestionMap(questions[index+1].difficulty);
    nextQuestion(currentGame.questionsOrder[index]);
    databaseService.cheatByJumpingQuestion(currentGame.id, true);
    setState( () {
      index++;
      finishQuestion = false;
      isSelectedItem = [false, false, false, false];
      playerAnsweredQuestion = false;
    });
  }

  void jumpQuestionForPatient() async {
    await databaseService.cheatByJumpingQuestion(currentGame.id, false);
    Future.delayed(
        const Duration(seconds: 2),
            () {
          setState(() {
            nextQuestion(currentGame.questionsOrder[index]);
            setState( () {
              index++;
              finishQuestion = false;
              isSelectedItem = [false, false, false, false];
              playerAnsweredQuestion = false;
            });
          });
        }
    );
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
  final String imagePath;

  QuizComponent({Key key, this.question, this.parent, this.isSelectedItem, this.displayAvancement, this.imagePath }) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
            height: MediaQuery.of(context).size.height / 10,
            decoration: BoxDecoration(
                color: question.difficulty.color,
            ),
            child: Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Text(  displayAvancement + " : ${question.questionName}",
                      style: TextStyle(fontSize: 200, fontWeight: FontWeight.bold)),
                )),
          ),
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

class CustomCloserPanel extends StatelessWidget {
  final QuizViewState parent;

  CustomCloserPanel({this.parent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => closePanel(),
      child: Container(
          height: MediaQuery.of(context).size.height / 30,
          color: Theme.of(context).backgroundColor,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_arrow_down),
                Icon(Icons.keyboard_arrow_down),
                Icon(Icons.keyboard_arrow_down),
                SizedBox(width: 30.0),
                Center(child: Text("Prochaine Question", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                SizedBox(width: 30.0),
                Icon(Icons.keyboard_arrow_down),
                Icon(Icons.keyboard_arrow_down),
                Icon(Icons.keyboard_arrow_down),
              ]
          )
      ),
    );
  }

  void closePanel() {
    parent.closePanel();
  }
}


class ViewAnswerFromPlayer extends StatelessWidget {
  final String playerName;
  final bool hasAswered;
  final QuizViewState parent;

  ViewAnswerFromPlayer({this.playerName, this.hasAswered, this.parent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 10,
      decoration: BoxDecoration(
        color: hasAswered ? Colors.green : Colors.red
      ),
      child: Row(
          mainAxisAlignment: MyApp.isWebDevice ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width / 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                  height: MyApp.isWebDevice ? MediaQuery.of(context).size.height / 15 : 50,
                  width: MyApp.isWebDevice ? MediaQuery.of(context).size.width / 15 : 50,
                  child: Image.asset( "assets/images/$playerName.jpg",
                    fit: BoxFit.fill,
                  ),

              ),
            ),
            SizedBox(width: 10.0),
            Center(
                child:  playerName == "ACEceNhYQpHXAdSciepN" ?
                Text(
                    hasAswered ? "Franck a répondu à la question ! ": "Franck n'a pas encore répondu à la question",
                    style: TextStyle(fontWeight: FontWeight.bold)
                ) :
                Text(
                    hasAswered ? "Amélie a répondu à la question ! ": "Amélie n'a pas encore répondu à la question",
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
            ),
            SizedBox(width: MyApp.isWebDevice ? 20 : 0),
            Spacer(),
            Visibility(
              visible: MobileLoginPageState.status == 1 && !hasAswered,
              child: Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  width: MediaQuery.of(context).size.width / 6,
                  height: MediaQuery.of(context).size.height / 15,
                  child: FlatButton(
                    onPressed: () => jumpToNextQuestion(),
                    child: Text("Sauter la question"),
                  ),
                ),
              ),
            )
          ]
        ),
    );
  }

  void jumpToNextQuestion() {
    parent.cheatToNextQuestion();
  }
}




