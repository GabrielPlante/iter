import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/services/databaseService.dart';

import 'components/quizCardComponentForMobile.dart';
import 'package:iter/views/QuizView.dart';

class MobileMainPage extends StatefulWidget {
  @override
  MobileMainPageState createState() => MobileMainPageState();
}

class MobileMainPageState extends State<MobileMainPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Quiz> quizs = [];
  String quizChosen = '';

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
      await _databaseService.removePlayer(quizId);
      setState(() {
        quizChosen = '';
      });
    } else {
      if(quizChosen != '') await _databaseService.removePlayer(quizChosen);
      await _databaseService.addPlayer(quizId);
      setState(() {
        quizChosen = quizId;
      });
    }
  }
}
