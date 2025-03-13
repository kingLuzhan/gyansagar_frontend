import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/resources/repository/teacher/teacher_repository.dart';
import 'package:get_it/get_it.dart';

class PollState extends ChangeNotifier {
  PollState() {
    question = '';
    lastTime = '';
  }

  List<String> pollOptions = ["", ""];
  late String question;
  String pollExpiry = "24 Hours";
  late String lastTime;

  set setPollExpiry(String value) {
    pollExpiry = value;
    notifyListeners();
  }

  void addValueToPollOption(String value, int index) {
    pollOptions[index] = value;
  }

  void removePollOption(int index) {
    var val = pollOptions[index];
    pollOptions.remove(val);
    notifyListeners();
  }

  void addPollOptions() {
    pollOptions.add("");
    notifyListeners();
  }

  Future<PollModel> createPoll(String question) async {
    try {
      pollOptions.removeWhere((element) => element.isEmpty);
      assert(pollOptions.isNotEmpty);

      var model = PollModel(
        id: '',
        question: question,
        options: pollOptions,
        endTime: DateTime.now().add(
          Duration(
            hours: int.parse(pollExpiry.split(" ")[0]),
          ),
        ),
        batches: [""],
        isForAll: true,
        answers: [],
        totalVotes: 0,
        votes: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final getit = GetIt.instance;
      final repo = getit.get<TeacherRepository>();
      await repo.createPoll(model);
      return model;
    } catch (error, stackTrace) {
      log("createPoll", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}