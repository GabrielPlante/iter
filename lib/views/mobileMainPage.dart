import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/services/databaseService.dart';
import 'components/quizCardComponentForMobile.dart';

class MobileMainPage extends StatefulWidget {
  static String userId = "Amelie";
  @override
  MobileMainPageState createState() => MobileMainPageState();
}

class MobileMainPageState extends State<MobileMainPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Quiz> quizs = [];
  String quizChosen = '';

  /*@override
  void dispose() {
    super.dispose();
    if (quizChosen != ''){
        _databaseService.removePlayer(quizChosen);
      }
  }*/

  @override
  void initState() {
    initQuizs();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Menu Principal')),
        body: quizs.isEmpty ? Text(" Nothing") :
        ListView.builder(
            itemCount: quizs.length,
            itemBuilder: (context, index) {
              return QuizCardComponentForMobile(quiz: quizs[index],quizJoined : quizs[index].id == quizChosen, parent: this );
            })
    );
  }


  void initQuizs() async {
    List<Quiz> result = await  _databaseService.allQuiz;
    setState(() {
      quizs = result;
    });

  }

  void updateQuizChoice(String quizId) async {
    if(quizChosen == quizId){
      await _databaseService.removePlayer(quizId, MobileMainPage.userId);
      setState(() {
        quizChosen = '';
      });
    } else {
      if(quizChosen != '') await _databaseService.removePlayer(quizChosen, MobileMainPage.userId);
      await _databaseService.addPlayer(quizId, MobileMainPage.userId);
      setState(() {
        quizChosen = quizId;
      });
    }
  }
}
