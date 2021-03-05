import 'package:flutter/material.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/stats.dart';
import 'package:iter/services/databaseService.dart';
import 'package:iter/views/mobileMainPage.dart';

class EndQuizForAdminMobile extends StatefulWidget {
  final Quiz quiz;
  final Game currentGame;
  final Stats statOfGame;

  EndQuizForAdminMobile({this.quiz,this.currentGame, this.statOfGame});


  @override
  EndQuizForAdminMobileState createState() => EndQuizForAdminMobileState();
}

class EndQuizForAdminMobileState extends State<EndQuizForAdminMobile> {
  List<Difficulty> newDifficulties = [];
  DatabaseService db = DatabaseService();

  @override
  void initState() {
    for(String qId in widget.currentGame.questionsOrder){
      newDifficulties.add( widget.quiz.questions.firstWhere((element) => element.id == qId).difficulty );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          /// add design trash shit
          Container(
            margin: EdgeInsets.only(top:10),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/city_wallpaper.jpg"),
                    fit: BoxFit.cover
                )
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.5,
            child: ListView.builder(
                itemCount: widget.quiz.questions.length,
                itemBuilder: (context, index) {
                  Question question = widget.quiz.questions.firstWhere( (element) => element.id == widget.currentGame.questionsOrder[index] );
                  return QuestionChanger(question: question, index: index, statOfGame: widget.statOfGame, hasBeenSkipped: !widget.currentGame.avancementByQuestionMap[question.id][0] && !widget.currentGame.avancementByQuestionMap[question.id][1], parent: this, selectedDifficulty: newDifficulties[index]);
                },
            ),
          ),
          Center(
            child: FlatButton(
              onPressed: () => endGame(),
              child: Text("Terminer"),
            ),
          )
        ],
      ),
    );
  }

  void changeDifficultyOfQuestion(Difficulty difficulty, int index) {
    setState(() {
      newDifficulties[index] = difficulty;
    });
  }

  void endGame() async {
    for(Question q in widget.quiz.questions) {
      Difficulty dif = newDifficulties[widget.currentGame.questionsOrder.indexOf(q.id)];
      if(q.difficulty == dif ) {
        await db.updateQuestionDifficulty(widget.quiz.id, q.id, dif);
      }

      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute( builder: (context) => MobileMainPage() )
      );
    }

  }
}


class QuestionChanger extends StatelessWidget {
  final Question question;
  final int index;
  final Stats statOfGame;
  final bool hasBeenSkipped;
  final EndQuizForAdminMobileState parent;
  final Difficulty selectedDifficulty;

  QuestionChanger({this.question, this.index, this.statOfGame, this.hasBeenSkipped, this.parent, this.selectedDifficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: hasBeenSkipped ? Colors.grey : question.difficulty.color,
      child: Column(
        children: [
          Center(
            child: Text(question.questionName)
          ),
          hasBeenSkipped ?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Aides : ${statOfGame.nbrOfDeletedAnswers[index]}"),
              Text("Erreurs : ${statOfGame.nbrOfWrongAnswers[index]}")
            ],
          ) :
          Center( child: Text("Cette question a été sautée..."),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    Difficulty newDifficulty = Difficulty.values[selectedDifficulty.index - 1 < 0 ? Difficulty.INSANE.index : selectedDifficulty.index - 1];
                    parent.changeDifficultyOfQuestion(newDifficulty, index);
                  },
              ),
              Text(selectedDifficulty.name),
              IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    Difficulty newDifficulty = Difficulty.values[selectedDifficulty.index + 1 > Difficulty.INSANE.index ? Difficulty.EASY.index : selectedDifficulty.index + 1];
                    parent.changeDifficultyOfQuestion(newDifficulty, index);
                  },
              )
            ],
          )
        ],
      ),
    );
  }


}

