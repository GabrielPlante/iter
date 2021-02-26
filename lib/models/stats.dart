import 'package:iter/views/webMainPage.dart';

class Stats{
  List<int> nbrOfWrongAnswers = [];
  List<int> nbrOfDeletedAnswers = [];

  int getTotalNbrOfWrongAnswers(){
    int t = 0;
    for (int i = 0; i != nbrOfWrongAnswers.length; i++){
      t += nbrOfWrongAnswers[i];
    }
    return t;
  }

  int getTotalNbrOfDeletedAnswers(){
    int t = 0;
    for (int i = 0; i != nbrOfDeletedAnswers.length; i++){
      t += nbrOfDeletedAnswers[i];
    }
    return t;
  }
}
