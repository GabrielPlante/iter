import 'package:flutter/material.dart';
import 'package:iter/models/question.dart';
import 'package:iter/views/QuizView.dart';
import 'package:badges/badges.dart';

class ChooseNextQuestionPanel extends StatelessWidget {
  final Map<Difficulty,int> availableQuestionsNumberMap;
  final Difficulty selectedNextDifficulty;
  final QuizViewState quizViewState;

  ChooseNextQuestionPanel({this.availableQuestionsNumberMap, this.selectedNextDifficulty, this.quizViewState});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 13,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DifficultyBox(difficulty:Difficulty.EASY, numberOfAvailableQuestions: availableQuestionsNumberMap[Difficulty.EASY], selectedNextDifficulty: selectedNextDifficulty, parent: this),
          DifficultyBox(difficulty: Difficulty.MODERATE, numberOfAvailableQuestions:availableQuestionsNumberMap[Difficulty.MODERATE], selectedNextDifficulty: selectedNextDifficulty, parent: this),
          DifficultyBox(difficulty:Difficulty.DIFFICULT, numberOfAvailableQuestions: availableQuestionsNumberMap[Difficulty.DIFFICULT],selectedNextDifficulty: selectedNextDifficulty, parent: this),
          DifficultyBox(difficulty: Difficulty.INSANE, numberOfAvailableQuestions: availableQuestionsNumberMap[Difficulty.INSANE], selectedNextDifficulty: selectedNextDifficulty, parent: this),
        ],
      )
    );
  }

  void changeSelectDifficulty(Difficulty newSelectedDifficulty) {
    quizViewState.changeSelectDifficulty(newSelectedDifficulty);
  }

  void callUpdateQuestionOrderFromParent() {
    quizViewState.verifyForChangeIndexForDifficulty();
  }
}


class DifficultyBox extends StatelessWidget {
  final Difficulty difficulty;
  final int numberOfAvailableQuestions;
  final Difficulty selectedNextDifficulty;
  final ChooseNextQuestionPanel parent;

  DifficultyBox({this.difficulty, this.numberOfAvailableQuestions, this.selectedNextDifficulty, this.parent});


  @override
  Widget build(BuildContext context) {
    return Badge(
      showBadge: numberOfAvailableQuestions != 0,
      badgeColor: Colors.blue,
      position: BadgePosition.topEnd(end: MediaQuery.of(context).size.width / 600),
      badgeContent: Center(child: Text(numberOfAvailableQuestions.toString())),
      child: Container(
        height: MediaQuery.of(context).size.height / 13,
        width: MediaQuery.of(context).size.width / 4,
        child: RaisedButton(
          disabledColor: Theme.of(context).backgroundColor,
            disabledTextColor: Colors.grey[600],
            onPressed: numberOfAvailableQuestions == 0 ? null : _buttonPressed ,
          color: selectedNextDifficulty == difficulty ? difficulty.color : Theme.of(context).backgroundColor,
            child: Center(
              child: Text(difficulty.name),
            ),
        ),
      ),
    );
  }

  void _buttonPressed() {
    if(difficulty != selectedNextDifficulty) {
      parent.changeSelectDifficulty(difficulty);
      parent.callUpdateQuestionOrderFromParent();
    }
  }
}


