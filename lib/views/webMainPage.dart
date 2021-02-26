import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/user.dart';
import 'package:iter/services/databaseService.dart';
import 'package:iter/views/quizViewWebDisplayer.dart';

class WebMainPage extends StatefulWidget {
  static User user;
  @override
  WebMainPageState createState() => WebMainPageState();
}

class WebMainPageState extends State<WebMainPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Quiz> quizs = [];
  List<User> allUser = [];
  String quizChosenByModerator = '';

  @override
  void initState() {
    initUser();
    initQuizs();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: quizs.length != 0 && allUser.length != 0 ?
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/city_wallpaper.jpg"),
                fit: BoxFit.cover
            )
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Quiz')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> query) {
              List<User> playersReady = [];
              Quiz currentQuiz;
              if(query.data != null ){
                for(DocumentSnapshot doc in query.data.docs){
                  int indexOfTheQuiz;
                  for(Quiz quiz in quizs) {
                    if(quiz.id == doc.id) indexOfTheQuiz = quizs.indexOf(quiz);
                  }
                  quizs[indexOfTheQuiz] = _databaseService.updateQuizPlayers(quizs[indexOfTheQuiz], doc);
                }

                for(Quiz quiz in quizs) {
                  if(quiz.waitingPlayers.length != 0 ) {
                    currentQuiz = quiz;
                    for(String userId in currentQuiz.waitingPlayers) {
                      if(allUser.where((element) => element.id == userId).first != null) {
                        playersReady.add(allUser.where((element) => element.id == userId).first);
                      }
                    }
                  }
                }
              }
              if(currentQuiz != null && playersReady.length == 2  && query.connectionState == ConnectionState.active) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute( builder: (context) => QuizViewWebDisplayer(quiz: currentQuiz, players: playersReady) )
                  );
                });
              }

              if(currentQuiz != null && playersReady.length == 1 ) return BodyWebMainView(quiz: currentQuiz, users: playersReady);
              else return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("Bienvenue sur Assist Quiz", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                      ),
                      Text("En attente d'un joueur", style: TextStyle(fontSize: 50, fontWeight: FontWeight.normal)),
                    ]
                  )
              );
            },
          ),
        )
            :
        CircularProgressIndicator(),
        );
  }

  void initUser() async {
    List<User> result = await _databaseService.allUser;
    allUser = result;
    for(User userResult in result) {

      if(userResult.isInterfaceWeb) {
        setState(() {
          WebMainPage.user = userResult;
          print(WebMainPage.user.name);
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
}

class BodyWebMainView extends StatelessWidget {
  final Quiz quiz;
  final List<User> users;

  BodyWebMainView({this.quiz, this.users});

  @override
  Widget build(BuildContext context) {
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
                  child: Text(users.length == 2 ? "La partie va commencer ! " : "En attente du 2ème joueur...", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)
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
                          height: 250,
                          width: 250,
                          child: Image.asset( "assets/images/${users[0].id}.jpg",
                            fit: BoxFit.fill,
                          ),

                        ),
                      ),
                      SizedBox(height: 20),
                      Text(users.length != 0 ? users[0].name :"Player 1",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                      )
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
                    child: Text( quiz.quizName, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold) ),
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
                          height: 250,
                          width: 250,
                          child: Image.asset( users.length == 2 ? "assets/images/${users[1].id}.jpg" : "assets/images/profil.jpg",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(users.length == 2 ? users[1].name :"Player 2",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                      )
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

