import 'package:iter/models/question.dart';

class Quiz {
  String id;
  String quizName;
  List<Question> questions;
  List<String> waitingPlayers;
  String imagePath;
  bool hasJoined;

  Quiz(String id, String quizName, List<Question> questions, List<String> waitingPlayers, String imagePath, bool hasJoined) {
    this.id = id;
    this.quizName = quizName;
    this.questions = questions;
    this.waitingPlayers = waitingPlayers;
    this.imagePath = imagePath;
    this.hasJoined = hasJoined;
  }

}