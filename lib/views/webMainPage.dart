import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/services/databaseService.dart';
import 'package:iter/views/components/quizCardComponent.dart';

class WebMainPage extends StatefulWidget {
  static String userId = "Franck";
  @override
  WebMainPageState createState() => WebMainPageState();
}

class WebMainPageState extends State<WebMainPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Quiz> quizs = [];
  String quizChosen = '';

  /*@override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if(AppLifecycleState.paused == state) {
      if (quizChosen != ''){
        _databaseService.removePlayer(quizChosen);
      }
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
      body: quizs.isEmpty ?
      Center(child: CircularProgressIndicator())
          :
      ListView.builder(
        itemCount: quizs.length,
        itemBuilder: (context, index) {
          //return QuizView(quiz: quizs[index]);
          return QuizCardComponent(quiz: quizs[index],quizJoined : quizs[index].id == quizChosen, parent: this );
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
      await _databaseService.removePlayer(quizId, WebMainPage.userId);
      setState(() {
        quizChosen = '';
      });
    } else {
      if(quizChosen != '') await _databaseService.removePlayer(quizChosen, WebMainPage.userId);
      await _databaseService.addPlayer(quizId, WebMainPage.userId);
      setState(() {
        quizChosen = quizId;
      });
    }
  }
}
