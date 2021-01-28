import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iter/models/question.dart';
import 'package:iter/models/quiz.dart';

class DatabaseService {
  List<Quiz> quizs = [];

  final CollectionReference quizCollection = FirebaseFirestore.instance.collection('Quiz');

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

      Question question = Question(doc['questionName'], doc['correctAnswer'], answers);
      questions.add(question);
    }

    return questions;
  }



  Future<List<Quiz>> get allQuiz async {
    QuerySnapshot quizQueries = await quizCollection.get();

    if(quizQueries == null) return null;

    for(DocumentSnapshot document in quizQueries.docs) {
      CollectionReference questionsOfQuizCollection = quizCollection.doc(document.id).collection("questions");

      List<Question> questions = await getQuestionsForQuiz(questionsOfQuizCollection);

      Quiz quiz = Quiz(document['quizName'], questions);
      quizs.add(quiz);

    }

    return quizs;
  }

}