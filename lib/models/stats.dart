class Stats{
  String id;
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

  Stats(String id, List<int> nbrOfWrongAnswers, List<int> nbrOfDeletedAnswers){
    this.id = id;
    this.nbrOfDeletedAnswers =nbrOfDeletedAnswers;
    this.nbrOfWrongAnswers = nbrOfWrongAnswers;
  }
}
