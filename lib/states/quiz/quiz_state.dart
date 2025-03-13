import 'dart:async';
import 'dart:developer';

import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';

class QuizState extends BaseState {
  // Make batchId required, no longer nullable
  QuizState({required this.batchId}) {
    print("Create State instance");
  }

  final String batchId;

  // Initialize with empty list, or you can initialize later in methods
  List<AssignmentModel> assignmentsList = []; // Initialized to an empty list

  // Initialize quizModel with a default constructor (no dummyData)
  QuizDetailModel quizModel = QuizDetailModel(
    title: '',
    duration: 0,
    owner: '',
    batch: '',
    questions: [],
    answers: [],
    createdAt: '',
    updatedAt: '',
  );

  void addAnswer(Question value) {
    var data = quizModel.questions.firstWhere((element) => element.id == value.id);
    data.selectedAnswer = value.selectedAnswer;
    notifyListeners();
  }

  Future<void> getQuizList() async {
    await execute(() async {
      isBusy = true;
      final repo = GetIt.instance.get<BatchRepository>();
      assignmentsList = await repo.getAssignmentList(batchId);
      notifyListeners();
      isBusy = false;
    }, label: "getQuizList");
  }

  Future<void> getAssignmentDetail(String assignmentId) async {
    await execute(() async {
      isBusy = true;
      final repo = GetIt.instance.get<BatchRepository>();
      quizModel = await repo.getAssignmentDetailList(batchId, assignmentId);
      isBusy = false;
      notifyListeners();
    }, label: "getAssignmentDetail");
  }

  Future<bool> deleteQuiz(String videoId) async {
    try {
      var isDeleted = await deleteById("batch/$batchId/${Constants.crudAssignment(videoId)}");
      if (isDeleted) {
        assignmentsList.removeWhere((element) => element.id == videoId);
        notifyListeners();
      }
      return isDeleted;
    } catch (error) {
      log("deleteQuiz error", error: error, name: runtimeType.toString());
      return false;
    }
  }
}
