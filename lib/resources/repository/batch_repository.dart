import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_timeline_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/session/session.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';

class BatchRepository {
  final ApiGateway gateway;
  final SessionService sessionService;

  BatchRepository(this.gateway, this.sessionService);

  Future<bool> createBatch(BatchModel model) {
    return gateway.createBatch(model);
  }

  Future<AnnouncementModel> createAnnouncement(AnnouncementModel model,
      {bool? isEdit}) {
    return gateway.createAnnouncement(model, isEdit: isEdit ?? false);
  }

  Future<bool> login(ActorModel model) async {
    var actor = await gateway.login(model);
    await sessionService.saveSession(actor);
    return true;
  }

  Future<bool> register(ActorModel model) async {
    return gateway.register(model);
  }

  Future<bool> updateUser(ActorModel model) async {
    var actor = await gateway.updateUser(model);
    await sessionService.saveSession(actor);
    return true;
  }

  Future<bool> forgotPassword(ActorModel model) async {
    return gateway.forgotPassword(model);
  }

  Future<bool> loginWithGoogle(String token) async {
    var actor = await gateway.loginWithGoogle(token);
    await sessionService.saveSession(actor);
    return true;
  }

  Future<bool> verifyOtp(ActorModel model) async {
    var actor = await gateway.verifyOtp(model);
    await sessionService.saveSession(actor);
    return true;
  }

  Future<List<BatchModel>> getBatch() {
    return gateway.getBatches();
  }

  Future<bool> deleteById(String typeAndId) {
    return gateway.deleteBatch(typeAndId);
  }

  Future<List<AnnouncementModel>> getAnnouncementList() {
    return gateway.getAnnouncementList(); // Assuming API still has the typo
  }

  Future<List<PollModel>> getPollList() {
    return gateway.getPollList();
  }

  Future<List<NotificationModel>> getStudentNotificationsList() {
    return gateway.getStudentNotificationsList();
  }

  Future<List<VideoModel>> getVideosList(String batchId) {
    return gateway.getVideosList(batchId);
  }

  Future<List<BatchMaterialModel>> getBatchMaterialList(String batchId) {
    return gateway.getBatchMaterialList(batchId);
  }

  Future<List<AnnouncementModel>> getBatchAnnouncementList(String batchId) {
    return gateway.getBatchAnnouncementList(
        batchId); // Assuming API still has the typo
  }

  Future<List<BatchTimeline>> getBatchDetailTimeLine(String batchId) {
    return gateway.getBatchDetailTimeLine(batchId);
  }

  Future<List<AssignmentModel>> getAssignmentList(String batchId) {
    return gateway.getAssignmentList(batchId);
  }

  Future<QuizDetailModel> getAssignmentDetailList(String batchId,
      String assignmentId) {
    return gateway.getAssignmentDetailList(batchId, assignmentId);
  }

  Future<PollModel> castVoteOnPoll(String pollId, String vote) {
    return gateway.castVoteOnPoll(pollId, vote);
  }

  // Add the missing methods
  Future<void> savePollSelection(PollModel poll) async {
    return gateway.savePollSelection(poll);
  }

  Future<void> expirePoll(String pollId) async {
    return gateway.expirePoll(pollId);
  }

  Future<void> deletePoll(String pollId) async {
    return gateway.deletePoll(pollId);


    Future<List<BatchMaterialModel>> getBatchMaterialList(String batchId) async {
      return await gateway.getBatchMaterialList(batchId);
    }

    Future<List<AnnouncementModel>> getBatchAnnouncementList(
        String batchId) async {
      return await gateway.getBatchAnnouncementList(batchId);
    }

    Future<List<AssignmentModel>> getAssignmentList(String batchId) async {
      return await gateway.getAssignmentList(batchId);
    }
  }
}