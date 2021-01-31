import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';

class DatabaseService {
  List<Quiz> quizs = [];
  List<Game> games = [];

  final CollectionReference quizCollection = FirebaseFirestore.instance.collection('Quiz');

  final CollectionReference gameCollection = FirebaseFirestore.instance.collection('Game');

  Future<List<Question>> getQuestionsForQuiz(CollectionReference questionsOfQuizCollection) async {
    List<Question> questions = [];

    QuerySnapshot questionsQueries = await questionsOfQuizCollection.get();

    if (questionsQueries == null) return null;

    for(DocumentSnapshot doc in questionsQueries.docs){
      List<String> answers =[];

      if(doc['answers'] != null) {
        doc['answers'].forEach((dy) {
          answers.add(dy);
        });
      }

      Question question = Question(doc.id, doc['questionName'], doc['correctAnswer'], answers);
      questions.add(question);
    }
    return questions;
  }



  Future<List<Quiz>> get allQuiz async {
    QuerySnapshot quizQueries = await quizCollection.get();

    if(quizQueries == null) return null;

    for(DocumentSnapshot document in quizQueries.docs) {
      CollectionReference questionsOfQuizCollection = quizCollection.doc(document.id).collection("questions");

      List<Question> questions = await getQuestionsForQuiz(questionsOfQuizCollection);

      List<String> waitingPlayers = List.castFrom(document['waitingPlayers'] as List ?? []);


      Quiz quiz = Quiz(document['id'], document['quizName'], questions,waitingPlayers);
      quizs.add(quiz);

    }

    return quizs;
  }

  Future<List<Game>> get allGame async {
    QuerySnapshot gameQueries = await gameCollection.get();

    if(gameQueries == null) return null;

    for(DocumentSnapshot document in gameQueries.docs) {
      DateTime dateOfGame = document['dateOfGame'].toDate() ?? null;
      List<String> playersId = List.castFrom(document['playersId'] as List ?? []);

      Map<String, List<bool>> avancementByQuestionMap = Map();
      if(document['avancementByQuestionMap'] != null) {
        document['avancementByQuestionMap'].forEach((key, value) {
          String questionId = key;
          List<bool> avancencement = List.castFrom(document['avancementByQuestionMap'][questionId] as List ?? []);

          avancementByQuestionMap[questionId] = avancencement;
        });
      }

      Map<String, int> scoreByPlayerMap = Map();
      if(document['scoreByPlayerMap'] != null) {
        document['scoreByPlayerMap'].forEach((key, value) {
          scoreByPlayerMap[key] = value.toInt();
        });
      }

      Game game = Game.AlreadyExisting(document.id, document['quizId'], dateOfGame, playersId, avancementByQuestionMap, scoreByPlayerMap);

      games.add(game);
    }

    return games;
  }

  Future createGame(String quizId, List<String> playersId, List<Question> questions) async {
    DateTime dateOfGame = DateTime.now();
    Map<String,List<bool>> avancementByQuestionMap = HashMap();
    Map<String,int> scoreByPlayerMap = HashMap();

    for(Question question in questions) {

      List<bool> avancementByPlayer = [];
      for(int i = 0; i < playersId.length; i++) {
        avancementByPlayer.add(false);
      }

      avancementByQuestionMap[question.id] = avancementByPlayer;
    }

    for(String playerId in playersId) {
      scoreByPlayerMap[playerId] = 0;
    }

    await gameCollection.add({
      'quizId' : quizId,
      'playersId' : playersId,
      'dateOfGame' : dateOfGame,
      'avancementByQuestionMap' : avancementByQuestionMap,
      'scoreByPlayerMap' : scoreByPlayerMap
    });
  }

  Game updateGame(DocumentSnapshot document) {
    DateTime dateOfGame = document['dateOfGame'].toDate() ?? null;
    List<String> playersId = List.castFrom(document['playersId'] as List ?? []);

    Map<String, List<bool>> avancementByQuestionMap = Map();
    if(document['avancementByQuestionMap'] != null) {
      document['avancementByQuestionMap'].forEach((key, value) {
        String questionId = key;
        List<bool> avancencement = List.castFrom(document['avancementByQuestionMap'][questionId] as List ?? []);

        avancementByQuestionMap[questionId] = avancencement;
      });
    }

    Map<String, int> scoreByPlayerMap = Map();
    if(document['scoreByPlayerMap'] != null) {
      document['scoreByPlayerMap'].forEach((key, value) {
        scoreByPlayerMap[key] = value.toInt();
      });
    }

    Game game = Game.AlreadyExisting(document.id, document['quizId'], dateOfGame, playersId, avancementByQuestionMap, scoreByPlayerMap);

    return game;
  }

  Future addPlayer(String quizId, String playerId) async {
    await quizCollection.doc(quizId).update( { 'waitingPlayers' : FieldValue.arrayUnion([playerId]) } );
  }

  Future removePlayer(String quizId, String playerId) async {
    await quizCollection.doc(quizId).update( { 'waitingPlayers' : FieldValue.arrayRemove([playerId]) } );
  }

  Future setQuestionFinished(String gameId, String questionId, Map<String,List<bool>> newAvancementMap) async {
    await gameCollection.doc(gameId).update({'avancementByQuestionMap' : newAvancementMap });
  }

}