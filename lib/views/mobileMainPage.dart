import 'package:flutter/material.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/user.dart';
import 'package:iter/services/databaseService.dart';
import 'package:iter/views/components/mobileLoginPage.dart';
import 'components/loadingScreen.dart';
import 'components/quizCardComponentForMobile.dart';

class MobileMainPage extends StatefulWidget {
  static User user;

  @override
  MobileMainPageState createState() => MobileMainPageState();
}

class MobileMainPageState extends State<MobileMainPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Quiz> quizs = [];
  String quizChosen = '';
  String previousGameId = '';

  @override
  void initState() {
    initUser();
    initQuizs();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Center(child: Text('Menu Principal')),

        ),
        body: quizs.isEmpty ?
        Center(child: LoadingScreen())
            :
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/city_wallpaper.jpg"),
                  fit: BoxFit.cover
              )
          ),
          child: Container(
            margin: EdgeInsets.only(top:10),
            child: ListView.builder(
                itemCount: quizs.length,
                itemBuilder: (context, index) {
                  return QuizCardComponentForMobile(quiz: quizs[index],quizJoined : quizs[index].id == quizChosen, parent: this, previousGameId: previousGameId );
                }),
          ),
        )
    );
  }

  void initUser() async {
    List<User> result = await _databaseService.allUser;
    for(User userResult in result) {
      if(userResult.isModerator == (MobileLoginPageState.status == 1) && !userResult.isInterfaceWeb) {
        setState(() {
          MobileMainPage.user = userResult;
          previousGameId = MobileMainPage.user.currentGameId;
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
