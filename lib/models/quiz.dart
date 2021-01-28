import 'package:iter/models/question.dart';

class Quiz {
  String id;
  String quizName;
  List<Question> questions;
  int numberOfPlayers;

  Quiz(String id, String quizName, List<Question> questions, int numberOfPlayers) {
    this.id = id;
    this.quizName = quizName;
    this.questions = questions;
    this.numberOfPlayers = numberOfPlayers;
  }

}