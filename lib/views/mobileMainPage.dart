import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/user.dart';
import 'package:iter/services/databaseService.dart';
import 'components/quizCardComponentForMobile.dart';

class MobileMainPage extends StatefulWidget {
  static String userName = "Amelie";
  static User user;

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
    initUser();
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

  void initUser() async {
    List<User> result = await _databaseService.allUser;
    for(User userResult in result) {
      if(userResult.name == MobileMainPage.userName) {
        setState(() {
          MobileMainPage.user = userResult;
          print(MobileMainPage.user.name);
        });
      }
    }

  }


  void initQuizs() async {
    List<Quiz> result = await  _databaseService.allQuiz;
    setState(() {
      quizs = result;
    });

  }

  void updateQuizChoice(String quizId) async {
    if(quizChosen == quizId){
      await _databaseService.removePlayer(quizId, MobileMainPage.user.id);
      setState(() {
        quizChosen = '';
      });
    } else {
      if(quizChosen != '') await _databaseService.removePlayer(quizChosen, MobileMainPage.user.id);
      await _databaseService.addPlayer(quizId, MobileMainPage.user.id);
      setState(() {
        quizChosen = quizId;
      });
    }
  }
}
