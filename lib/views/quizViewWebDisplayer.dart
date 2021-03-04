import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/user.dart';
import 'package:iter/models/stats.dart';
import 'package:iter/views/components/customAlertDialog.dart';
import 'package:iter/views/components/loadingScreen.dart';
import 'package:iter/views/webEndQuiz.dart';
import 'package:iter/views/webMainPage.dart';
import 'package:iter/services/databaseService.dart';

class QuizViewWebDisplayer extends StatefulWidget {
  final Quiz quiz;
  final List<User> players;

  QuizViewWebDisplayer({this.quiz, this.players});

  @override
  _QuizViewWebDisplayerState createState() => _QuizViewWebDisplayerState();
}

class _QuizViewWebDisplayerState extends State<QuizViewWebDisplayer> {
  List<Question> questions;
  DatabaseService databaseService = DatabaseService();
  Game currentGame;
  Stats gameStats;


  void newInitGame() async {
    User interface = WebMainPage.user;
    List result = await databaseService.getGameAndStatById(interface.currentGameId);

    setState(() {
      currentGame = result[0];
      gameStats = result[1];
    });
  }

  @override
  void initState() {
    questions = widget.quiz.questions;

    newInitGame();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentGame != null  ?
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<DocumentSnapshot>(
          stream : FirebaseFirestore.instance.collection('Game').doc(currentGame.id).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> documentSnapshot) {

            if (!documentSnapshot.hasData) {
              return Center(child: LoadingScreen());
            }

            DocumentSnapshot document = documentSnapshot.data;
            List updateDatas = databaseService.updateGameAndStat(document);
            currentGame = updateDatas[0];
            gameStats = updateDatas[1];

            if(currentGame.getQuestionHelp) handlerHelpDisplayer();

            if(currentGame.indexOfQuestion >= widget.quiz.questions.length) return WebEndQuiz();
            else return BodyQuizViewDisplayer(quiz: widget.quiz, questions: questions, currentGame: currentGame, players: widget.players);
          },
        ),
      )
          :
      LoadingScreen(),
    );
  }

  handlerHelpDisplayer() {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return CustomAlertDialog();
        },
    );
  }

  void handlerNextQuestion() {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
            ),
            child: Stack(
              overflow: Overflow.visible,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                    child: Column(
                      children: [
                        Text("Changeons un peu les règles !", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.green),),
                        SizedBox(height: 15),
                        Text('La difficulté va changer...', style: TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height:120,
                      width:120,
                      child: Image.asset("assets/images/977.png", fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            )
        );
      },
    );
  }
}


class BodyQuizViewDisplayer extends StatelessWidget {
  final Quiz quiz;
  final List<Question> questions;
  final Game currentGame;
  final List<User> players;

  BodyQuizViewDisplayer({this.quiz, this.questions, this.currentGame, this.players});

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = quiz.questions.firstWhere((element) => element.id == currentGame.questionsOrder[currentGame.indexOfQuestion]);
    Question nextQuestion;
    if(currentGame.indexOfQuestion + 1 < quiz.questions.length )  nextQuestion = quiz.questions.firstWhere((element) => element.id ==currentGame.questionsOrder[currentGame.indexOfQuestion + 1]);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/back/${quiz.imagePath}.jpg"),
          fit: BoxFit.cover
        )
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.4,
              margin: EdgeInsets.only(top: 100),
              decoration: BoxDecoration(
                color: currentQuestion.difficulty.color,
                borderRadius: BorderRadius.circular(30)
              ),
              child: Center(
                  child: Text("Question ${currentGame.indexOfQuestion+1} / ${currentGame.questionsOrder.length} : ${currentQuestion.questionName}", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold)
                  )
              )
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: 250,
                          width: 250,
                          child: Image.asset( "assets/images/${players[0].id}.jpg",
                            fit: BoxFit.cover,
                          ),

                        ),
                      ),
                      SizedBox(height: 20),
                      Center(child: Text(players[0].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40) )),
                      SizedBox(height: 10),
                      Center(child: ListingAvancementContainer(questions: questions, avancement: currentGame.avancementByQuestionMap, indexPlayer: 0, positionInQuiz: currentGame.indexOfQuestion)),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: 250,
                          width: 250,
                          child: Image.asset("assets/images/${players[1].id}.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(child: Text(players[1].name,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40) )),
                      SizedBox(height: 10),
                      Center(child: ListingAvancementContainer(questions: questions, avancement: currentGame.avancementByQuestionMap, indexPlayer: 1, positionInQuiz: currentGame.indexOfQuestion)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width / 3.5,
              margin: EdgeInsets.only(bottom: 100),
              decoration: BoxDecoration(
                  color: currentQuestion.difficulty.color,
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Visibility(
                visible: nextQuestion != null,
                child: Center(
                    child: Text("La prochaine question sera ${nextQuestion.difficulty.name}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                    )
                ),
              )
          )
        ],
      ),
    );
  }
}

class ListingAvancementContainer extends StatelessWidget {
  final List<Question> questions;
  final Map<String,List<bool>> avancement;
  final int indexPlayer;
  final int positionInQuiz;

  ListingAvancementContainer({this.questions,this.avancement, this.indexPlayer, this.positionInQuiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width / 6,
      height: MediaQuery.of(context).size.height / 20,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: positionInQuiz,
          itemBuilder: (context, index) {
            return Icon(
              Icons.assignment_turned_in,
              color: avancement[questions[index].id][indexPlayer] ? Colors.green : Colors.grey,
            );
          }),
    );
  }
}

