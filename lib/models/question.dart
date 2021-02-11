import 'dart:core';

import 'package:flutter/material.dart';

class Question {
  String id;
  String questionName;
  String correctAnswer;
  List<String> answers;
  Difficulty difficulty;

  Question(String id, String questionName, String correctAnswer, List<String> answers, Difficulty difficulty){
    if(answers.contains(correctAnswer)) {
      this.id = id;
      this.questionName = questionName;
      this.correctAnswer = correctAnswer;
      this.answers = answers;
      this.difficulty = difficulty;
    } else {
      /// throw error
    }
  }
}

enum Difficulty {
  EASY,
  MODERATE,
  DIFFICULT,
  INSANE,
}

extension DifficultyExtension on Difficulty {

  String get name {
    switch (this) {
      case Difficulty.EASY:
        return "Facile";
      case Difficulty.MODERATE:
        return "Modérée";
      case Difficulty.DIFFICULT:
        return "Difficile";
      case Difficulty.INSANE:
        return "Expert";
      default:
        return null;
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.EASY:
        return Colors.green;
      case Difficulty.MODERATE:
        return Colors.orange;
      case Difficulty.DIFFICULT:
        return Colors.red;
      case Difficulty.INSANE:
        return Colors.red[900];
      default:
        return null;
    }
  }
}