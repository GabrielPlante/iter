import 'package:iter/models/question.dart';

class Quiz {
  String id;
  String quizName;
  List<Question> questions;
  List<String> waitingPlayers;

  Quiz(String id, String quizName, List<Question> questions, List<String> waitingPlayers) {
    this.id = id;
    this.quizName = quizName;
    this.questions = questions;
    this.waitingPlayers = waitingPlayers;
  }

}