import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iter/models/game.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';
import 'package:iter/models/stats.dart';
import 'package:iter/models/user.dart';

class DatabaseService {
  List<Quiz> quizs = [];
  List<Game> games = [];

  final CollectionReference quizCollection = FirebaseFirestore.instance.collection('Quiz');
  final CollectionReference gameCollection = FirebaseFirestore.instance.collection('Game');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('User');

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

      Difficulty difficulty = Difficulty.values.firstWhere((element) => element.toString() == "Difficulty.${doc['difficulty']}");

      Question question = Question(doc.id, doc['questionName'], doc['correctAnswer'], answers, difficulty );
      questions.add(question);
    }
    return questions;
  }

  Future<void> updateQuestionDifficulty(String quizId, String questionId, Difficulty newDifficulty) async {
    await quizCollection.doc(quizId).collection("questions").doc(questionId).update( {'difficulty ' : newDifficulty} );
  }



  Future<List<Quiz>> get allQuiz async {
    QuerySnapshot quizQueries = await quizCollection.get();

    if(quizQueries == null) return null;

    for(DocumentSnapshot document in quizQueries.docs) {
      CollectionReference questionsOfQuizCollection = quizCollection.doc(document.id).collection("questions");

      List<Question> questions = await getQuestionsForQuiz(questionsOfQuizCollection);

      List<String> waitingPlayers = List.castFrom(document['waitingPlayers'] as List ?? []);


      Quiz quiz = Quiz(document.id, document['quizName'], questions,waitingPlayers, document['imagePath'], document['hasJoined']);
      quizs.add(quiz);

    }

    return quizs;
  }

  Quiz updateQuizPlayers(Quiz quiz, DocumentSnapshot doc) {
    List<String> waitingPlayers = List.castFrom(doc['waitingPlayers'] as List ?? []);
    quiz.hasJoined = doc['hasJoined'];
    quiz.waitingPlayers = waitingPlayers;

    return quiz;
  }

  Future<List<User>> get allUser async {
    QuerySnapshot userQueries = await userCollection.get();
    List<User> users = [];

    if(userQueries == null) return null;

    for(DocumentSnapshot document in userQueries.docs) {


      String currentGameId;
      if(document['currentGameId'] == null) currentGameId = "none";
      else currentGameId = document['currentGameId'];

      int fontSize = document['fontSize'];


      User user = User(document.id, document["name"], document["isModerator"], fontSize.toDouble(), document["isLightTheme"], currentGameId, document['isInterfaceWeb']);

      users.add(user);
    }

    return users;
  }

  Future<User> updateUser(String userId) async {
    DocumentSnapshot document = await userCollection.doc(userId).get();


    String currentGameId;
    if(document['currentGameId'] == null) currentGameId = "none";
    else currentGameId = document['currentGameId'];
    int fontSize = document["fontSize"];


    User user = User(document.id, document["name"], document["isModerator"],fontSize.toDouble(), document["isLightTheme"], currentGameId, document['isInterfaceWeb']);

    return user;
  }

  Future<String> createGameAndStat(String quizId, List<String> playersId, List<Question> questions) async {
    DateTime dateOfGame = DateTime.now();
    List<String> questionsOrder = [];
    Map<String,List<bool>> avancementByQuestionMap = HashMap();
    Map<String,int> scoreByPlayerMap = HashMap();

    /// for the stats
    List<int> nbrOfWrongAnswers = [];
    List<int> nbrOfDeletedAnswers = [];

    for(Question question in questions) {
      questionsOrder.add(question.id);
      List<bool> avancementByPlayer = [];
      for(int i = 0; i < playersId.length; i++) {
        avancementByPlayer.add(false);
      }

      avancementByQuestionMap[question.id] = avancementByPlayer;
    }

    for(String playerId in playersId) {
      scoreByPlayerMap[playerId] = 0;
    }

    DocumentReference docRef = await gameCollection.add({
      'quizId' : quizId,
      'indexOfQuestion' : 0,
      'playersId' : playersId,
      'dateOfGame' : dateOfGame,
      'avancementByQuestionMap' : avancementByQuestionMap,
      'scoreByPlayerMap' : scoreByPlayerMap,
      'questionsOrder' : questionsOrder,
      'getQuestionHelp' : false,
      'skipQuestion' : 0,
      'nbrOfDeletedAnswers':nbrOfDeletedAnswers,
      'nbrOfWrongAnswers':nbrOfWrongAnswers
    });

    for(String playerId in playersId) {
      await userCollection.doc(playerId).update({ "currentGameId" : docRef.id });
    }

    await userCollection.doc("FgtfpFWMVs4VTHahPd1o").update({ "currentGameId" : docRef.id });

    return docRef.id;
  }

  List updateGameAndStat(DocumentSnapshot document)  {
    DateTime dateOfGame = document['dateOfGame'].toDate() ?? null;
    List<String> playersId = List.castFrom(document['playersId'] as List ?? []);

    List<String> questionsOrder = List.castFrom(document['questionsOrder'] as List ?? []);

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

    bool getQuestionHelp = document["getQuestionHelp"];
    int skipQuestion = document["skipQuestion"];
    int indexOfQuestion = document["indexOfQuestion"];


    Game game = Game.AlreadyExisting(document.id, indexOfQuestion, document['quizId'], dateOfGame, playersId, avancementByQuestionMap, scoreByPlayerMap, questionsOrder, getQuestionHelp, skipQuestion);

    List<int> nbrOfWrongAnswers = List.castFrom(document['nbrOfWrongAnswers'] as List ?? []);
    List<int> nbrOfDeletedAnswers = List.castFrom(document['nbrOfDeletedAnswers'] as List ?? []);

    Stats gameStat = Stats(document.id,nbrOfWrongAnswers, nbrOfDeletedAnswers) ;

    return [game,gameStat];
  }

  Future<List> getGameAndStatById(String id) async {
    DocumentSnapshot document = await gameCollection.doc(id).get();

    DateTime dateOfGame = document['dateOfGame'].toDate() ?? null;
    List<String> playersId = List.castFrom(document['playersId'] as List ?? []);

    List<String> questionsOrder = List.castFrom(document['questionsOrder'] as List ?? []);

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

    bool getQuestionHelp = document["getQuestionHelp"];
    int skipQuestion = document["skipQuestion"];
    int indexOfQuestion = document["indexOfQuestion"];

    List<int> nbrOfWrongAnswers = List.castFrom(document['nbrOfWrongAnswers'] as List ?? []);
    List<int> nbrOfDeletedAnswers = List.castFrom(document['nbrOfDeletedAnswers'] as List ?? []);


    Game game = Game.AlreadyExisting(document.id, indexOfQuestion, document['quizId'], dateOfGame, playersId, avancementByQuestionMap, scoreByPlayerMap, questionsOrder,getQuestionHelp,skipQuestion);

    Stats gameStat = Stats(document.id,nbrOfWrongAnswers, nbrOfDeletedAnswers) ;

    return [game,gameStat];

  }

  Future addPlayer(String quizId, String playerId) async {
    await quizCollection.doc(quizId).update( { 'waitingPlayers' : FieldValue.arrayUnion([playerId]) } );
  }

  Future removePlayer(String quizId, String playerId) async {
    await quizCollection.doc(quizId).update( { 'waitingPlayers' : FieldValue.arrayRemove([playerId]) } );
  }

  Future removeWaitingPlayers(String quizId, List<String> players) async {
    await quizCollection.doc(quizId).update({ 'waitingPlayers': FieldValue.arrayRemove(players) });
  }

  Future setQuestionFinished(String gameId, String questionId, Map<String,List<bool>> newAvancementMap) async {
    await gameCollection.doc(gameId).update({'avancementByQuestionMap' : newAvancementMap });
  }

  Future updateQuestionOrder(String gameId,List<String> newQuestionsOrder) async {
    await gameCollection.doc(gameId).update({'questionsOrder' : newQuestionsOrder });
  }

  Future questionHelp(String gameId, bool value) async {
    await gameCollection.doc(gameId).update({'getQuestionHelp' : value });
  }

  Future skipQuestion(String gameId, int value) async {
    await gameCollection.doc(gameId).update({'skipQuestion' : value });
  }

  Future updateIndexQuestion(String gameId, int index, int skipQuestions) async {
    await gameCollection.doc(gameId).update({'indexOfQuestion' : index + 1 + skipQuestions });
  }

  void setHasJoined(String quizId, bool hasJoined)  {
    if(hasJoined) quizCollection.doc(quizId).update({'hasJoined' : hasJoined });
    else quizCollection.doc(quizId).update({'hasJoined' : hasJoined, 'waitingPlayers' : [] });
  }

  Future updateStats(String gameId, List<int> nbrOfWrongAnswers, List<int> nbrOfDeletedAnswers) async {
    await gameCollection.doc(gameId).update({'nbrOfWrongAnswers' : nbrOfWrongAnswers,  'nbrOfDeletedAnswers' : nbrOfDeletedAnswers});
  }
}