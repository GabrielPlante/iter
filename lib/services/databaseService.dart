import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';

class DatabaseService {
  List<Quiz> quizs = [];

  final CollectionReference quizCollection = FirebaseFirestore.instance.collection('Quiz');

  final CollectionReference gameCollection = FirebaseFirestore.instance.collection('Game');

  Future<List<Question>> getQuestionsForQuiz(CollectionReference questionsOfQuizCollection) async {
    List<Question> questions = [];

    QuerySnapshot questionsQueries = await questionsOfQuizCollection.get();

    if (questionsQueries == null) return null;

    for(DocumentSnapshot doc in questionsQueries.docs){
      List<String> answers =[];
      print(doc.id);

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

  Future createGame(String quizId, List<String> playersId, List<Question> questions) async {
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
      'avacementByQuestionMap' : avancementByQuestionMap,
      'scoreByPlayerMap' : scoreByPlayerMap
    });
  }

  Future addPlayer(String quizId, String playerId) async {
    await quizCollection.doc(quizId).update( { 'waitingPlayers' : FieldValue.arrayUnion([playerId]) } );
  }

  Future removePlayer(String quizId, String playerId) async {
    await quizCollection.doc(quizId).update( { 'waitingPlayers' : FieldValue.arrayRemove([playerId]) } );
  }

}