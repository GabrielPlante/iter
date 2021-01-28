import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/views/QuizView.dart';
import 'package:iter/services/databaseService.dart';

class WebMainPage extends StatefulWidget {
  @override
  _WebMainPageState createState() => _WebMainPageState();
}

class _WebMainPageState extends State<WebMainPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Quiz> quizs = [];

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
          return QuizView(quiz: quizs[index]);
        })
    );
  }


  void initQuizs() async {
    List<Quiz> result = await  _databaseService.allQuiz;
    setState(() {
      quizs = result;
    });

  }
}
