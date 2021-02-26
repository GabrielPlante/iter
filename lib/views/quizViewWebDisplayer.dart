import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/user.dart';
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


  void newInitGame() async {
    User interface = WebMainPage.user;
    Game result = await databaseService.getGameById(interface.currentGameId);

    setState(() {
      currentGame = result;
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
              return Center(child: CircularProgressIndicator());
            }

            DocumentSnapshot document = documentSnapshot.data;
            currentGame = databaseService.updateGame(document);

            return BodyQuizViewDisplayer(quiz: widget.quiz, currentGame: currentGame, players: widget.players);
          },
        ),
      )
          :
      CircularProgressIndicator(),
    );
  }
}


class BodyQuizViewDisplayer extends StatelessWidget {
  final Quiz quiz;
  final Game currentGame;
  final List<User> players;

  BodyQuizViewDisplayer({this.quiz, this.currentGame, this.players});

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = quiz.questions.firstWhere((element) => element.id == currentGame.questionsOrder[currentGame.indexOfQuestion]);

    return Container(
      decoration: BoxDecoration(
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 100),
              child: Center(
                  child: Text(currentQuestion.questionName, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)
                  )
              )
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width / 6,
                          child: Image.asset( "assets/images/${players[0].id}.jpg",
                            fit: BoxFit.fill,
                          ),

                        ),
                      ),
                      SizedBox(height: 20),
                      Text(players[0].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30) )
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                        image: AssetImage("assets/images/back/${quiz.imagePath}.jpg"),
                        fit: BoxFit.cover
                    ),
                  ),
                  child: Center(
                    child: Text( quiz.quizName, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold) ),
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width / 6,
                          child: Image.asset("assets/images/${players[1].id}.jpg",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(players[1].name,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30) )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
