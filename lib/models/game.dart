import 'dart:collection';
import 'package:iter/models/question.dart';

class Game {
  String id;
  String quizId;
  List<String> playersId;

  Map<String,List<bool>> avancementByQuestionMap = HashMap();
  Map<String,int> scoreByPlayerMap = HashMap();

  Game(String quizId, List<Question> questions, List<String> playersId){
    this.quizId = quizId;
    this.playersId = playersId;


    for(Question question in questions) {
      List<bool> avancementByPlayer = [];
      for(int i=0; i < playersId.length; i++) {
        avancementByPlayer.add(false);
      }

      this.avancementByQuestionMap[question.id] = avancementByPlayer;
    }

    for(String playerId in playersId) {
      this.scoreByPlayerMap[playerId] = 0;
    }
  }

}