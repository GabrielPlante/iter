import 'dart:collection';
import 'package:iter/models/question.dart';

class Game {
  String id;
  DateTime dateOfGame;
  String quizId;
  List<String> playersId;
  List<String> questionsOrder = [];

  Map<String,List<bool>> avancementByQuestionMap = HashMap();
  Map<String,int> scoreByPlayerMap = HashMap();

  Game(String quizId, DateTime dateOfGame, List<Question> questions, List<String> playersId){
    this.quizId = quizId;
    this.dateOfGame = dateOfGame;
    this.playersId = playersId;


    for(Question question in questions) {
      questionsOrder.add(question.id);
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

  Game.AlreadyExisting(String id, String quizId, DateTime dateOfGame, List<String> playersId, Map<String,List<bool>> avancementByQuestionMap, Map<String,int>scoreByPlayerMap, List<String> questionsOrder) {
    this.id = id;
    this.quizId = quizId;
    this.dateOfGame = dateOfGame;
    this.playersId = playersId;
    this.avancementByQuestionMap = avancementByQuestionMap;
    this.scoreByPlayerMap = scoreByPlayerMap;
    this.questionsOrder = questionsOrder;
  }

}