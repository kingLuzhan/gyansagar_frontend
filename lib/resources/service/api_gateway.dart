import 'dart:io';

import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_timeline_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';

abstract class ApiGateway {
  Future<dynamic> getUser();
  Future<bool> createBatch(BatchModel model);
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel model, {bool isEdit});
  Future<VideoModel> addVideo(VideoModel model, {bool isEdit});
  Future<ActorModel> login(ActorModel model);
  Future<bool> register(ActorModel model);
  Future<ActorModel> updateUser(ActorModel model);
  Future<bool> forgotPassword(ActorModel model);
  Future<ActorModel> loginWithGoogle(String token);
  Future<ActorModel> verifyOtp(ActorModel model);
  Future<List<BatchModel>> getBatches();
  Future<bool> deleteBatch(String batchId);
  Future<bool> createPoll(PollModel model);
  Future<bool> expirePollById(String pollId);
  Future<List<AnnouncementModel>> getAnnouncementList();
  Future<List<PollModel>> getPollList();
  Future<List<ActorModel>> getStudentList();
  Future<List<String>> getSubjectList();
  Future<List<NotificationModel>> getStudentNotificationsList();
  Future<List<VideoModel>> getVideosList(String batchId);
  Future<bool> uploadFile(File file, String id, {String? endpoint});
  Future<BatchMaterialModel> uploadMaterial(BatchMaterialModel model, {bool isEdit});
  Future<List<BatchMaterialModel>> getBatchMaterialList(String batchId);
  Future<List<AnnouncementModel>> getBatchAnnouncementList(String batchId);
  Future<List<AssignmentModel>> getAssignmentList(String batchId);
  Future<List<BatchTimeline>> getBatchDetailTimeLine(String batchId);
  Future<QuizDetailModel> getAssignmentDetailList(String batchId, String assignmentId);
  Future<PollModel> castVoteOnPoll(String pollId, String vote);
  Future<void> savePollSelection(PollModel poll);
  Future<void> expirePoll(String pollId);
  Future<void> deletePoll(String pollId);
}