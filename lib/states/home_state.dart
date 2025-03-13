import 'dart:developer';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/helper/enum.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';

class HomeState extends BaseState {
  List<BatchModel> batchList = [];
  List<AnnouncementModel> announcementList = [];
  List<PollModel> polls = [];
  List<PollModel> allPolls = [];
  String userId = '';
  Future<ActorModel?>? user; // Nullable Future
  bool isTeacher = true;

  Future<void> getBatchList() async {
    try {
      final getit = GetIt.instance;
      final pref = getit.get<SharedPreferenceHelper>();
      var userProfile = await pref.getUserProfile();
      if (userProfile != null) {
        userId = userProfile.id ?? ''; // Ensure id is not null
        isTeacher = userProfile.role == Role.TEACHER.asString();
      }
      final repo = getit.get<BatchRepository>();
      batchList = await repo.getBatch();
      notifyListeners();
    } catch (error) {
      log("getBatchList error", error: error, name: runtimeType.toString());
    }
  }

  Future<void> getPollList() async {
    try {
      final repo = GetIt.instance.get<BatchRepository>();
      polls = await repo.getPollList();
      if (polls.isNotEmpty) {
        polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        allPolls = List.from(polls);
        polls.removeWhere((poll) => poll.endTime.isBefore(DateTime.now()));
      }
      notifyListeners();
    } catch (error) {
      log("getPollList error", error: error, name: runtimeType.toString());
    }
  }

  Future<void> castVoteOnPoll(PollModel poll, String vote) async {
    if (isTeacher) {
      print("Teacher can't cast vote");
      return;
    }

    poll.selection?.loading = true;

    var model = await execute(() async {
      isBusy = true;
      final repo = GetIt.instance.get<BatchRepository>();
      return await repo.castVoteOnPoll(poll.id, vote);
    }, label: "castVoteOnPoll");

    if (model != null) {
      var index = polls.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        polls[index] = model;
      }
    }

    print("Voted successfully");
    poll.selection?.loading = false;
    isBusy = false;
  }

  Future<ActorModel?> getUser() async {
    final pref = GetIt.instance.get<SharedPreferenceHelper>();
    return user ??= pref.getUserProfile();
  }

  Future<bool> deleteBatch(String batchId) async {
    try {
      final repo = GetIt.instance.get<BatchRepository>();
      var isDeleted = await repo.deleteById(Constants.deleteBatch(batchId));
      if (isDeleted) {
        batchList.removeWhere((element) => element.id == batchId);
      }
      notifyListeners();
      return isDeleted;
    } catch (error) {
      log("deleteBatch error", error: error, name: runtimeType.toString());
      return false;
    }
  }

  Future<void> fetchAnnouncementList() async {
    try {
      final repo = GetIt.instance.get<BatchRepository>();
      announcementList = await repo.getAnnouncementList();
      notifyListeners();
    } catch (error) {
      log("fetchAnnouncementList error", error: error, name: runtimeType.toString());
    }
  }
}