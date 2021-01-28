import 'dart:core';

class Question {
  String questionName;
  String correctAnswer;
  List<String> answers;

  Question(String questionName, String correctAnswer, List<String> answers){
    if(answers.contains(correctAnswer)) {
      this.questionName = questionName;
      this.correctAnswer = correctAnswer;
      this.answers = answers;
    } else {
      /// throw error
    }
  }
}