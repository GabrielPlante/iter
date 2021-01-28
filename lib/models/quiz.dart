import 'package:iter/models/question.dart';

class Quiz {
  String quizName;
  List<Question> questions;

  Quiz(String quizName, List<Question> questions) {
    this.quizName = quizName;
    this.questions = questions;
  }

}