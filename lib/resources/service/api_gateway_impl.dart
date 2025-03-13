
import 'package:dio/dio.dart';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_timeline_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/model/notification_model.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/model/subject.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/dio_client.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/resources/service/notification_service.dart';
import 'package:get_it/get_it.dart';

class ApiGatewayImpl implements ApiGateway {
  final DioClient _dioClient;
  final SharedPreferenceHelper pref;
  ApiGatewayImpl(this._dioClient, {this.pref});

  @override
  Future getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<bool> createBatch(BatchModel model) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      var endpoint = model.id == null
          ? Constants.batch
          : Constants.editBatchDetail(model.id);
      var response = await _dioClient.post(endpoint,
          data: data, options: Options(headers: header));
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel model,
      {bool isEdit = false}) async {
    try {
      final mapJson = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      final endpoint = isEdit
          ? Constants.crudAnnouncement(model.id)
          : Constants.announcement;
      var response = await _dioClient.post(endpoint,
          data: mapJson, options: Options(headers: header));
      final map = _dioClient.getJsonBody(response);
      final data = AnnouncementModel.fromJson(map["announcement"]);
      return data;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<ActorModel> login(ActorModel model) async {
    try {
      final getit = GetIt.instance<NotificationService>();
      final fcmToken = await getit.getDeviceToken();
      model.fcmToken = fcmToken;
      final data = model.toJson();
      data.removeWhere((key, value) => value == null);
      var response = await _dioClient.post(
        Constants.login,
        data: data,
      );
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> register(ActorModel model) async {
    try {
      final getit = GetIt.instance<NotificationService>();
      final fcmToken = await getit.getDeviceToken();
      model.fcmToken = fcmToken;
      final data = model.toJson();
      var response = await _dioClient.post(
        Constants.register,
        data: data,
      );

      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> forgotPassword(ActorModel model) async {
    try {
      final data = model.toJson();
      data.removeWhere((key, value) => value == null);
      await _dioClient.post(Constants.forgotPassword, data: data);
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<ActorModel> verifyOtp(ActorModel model) async {
    try {
      final data = model.toJson();
      data.removeWhere((key, value) => value == null);
      var response = await _dioClient.post(
        Constants.verifyOtp,
        data: data,
      );
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<ActorModel> updateUser(ActorModel model) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      data.removeWhere((key, value) => value == null);
      var response = await _dioClient.post(
        Constants.profile,
        data: data,
        options: Options(headers: header),
      );
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<ActorModel> loginWithGoogle(String token) async {
    try {
      final header = {"Authorization": "Bearer " + token};
      var response = await _dioClient.get(Constants.googleAuth,
          options: Options(headers: header));
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<BatchModel>> getBatches() async {
    try {
      var token = await pref.getAccessToken();
      final header = {"Authorization": "Bearer " + token};
      bool isStudent = await pref.isStudent();
      var response = await _dioClient.get(
        Constants.getMyBatches(isStudent),
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final list = BatchResponseModel.fromJson(json);
      return list.batches;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> deleteBatch(String typeAndId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};

      await _dioClient.delete(
        typeAndId,
        options: Options(headers: header),
      );
      return true;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> createPoll(PollModel model) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      await _dioClient.post(Constants.poll,
          data: data, options: Options(headers: header));
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> expirePollById(String pollId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      await _dioClient.post(Constants.crudePoll(pollId) + "/end",
          options: Options(headers: header));
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncemantList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      bool isStudent = await pref.isStudent();

      final response = await _dioClient.get(
          Constants.getMyAnnouncement(isStudent),
          options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = AnnouncementListResponse.fromJson(json);
      return model.announcements;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<BatchTimeline>> getBatchDetailTimeLine(String batchId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      bool isStudent = await pref.isStudent();

      final response = await _dioClient.get(
          Constants.getMyBatchDetailTimeLine(isStudent, batchId),
          options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = BatchTimelineResponse.fromJson(json);
      return model.timeline;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<PollModel>> getPollList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      String endpoint =
      await pref.isStudent() ? Constants.studentPolls : Constants.poll;
      final response =
      await _dioClient.get(endpoint, options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = PollResponseModel.fromJson(json);
      return model.polls;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<ActorModel>> getStudentList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      final response = await _dioClient.get(Constants.getAllStudentList,
          options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = StudentResponseModel.fromJson(json);
      return model.students;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<String>> getSubjectList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      final response = await _dioClient.get(Constants.subjects,
          options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = SubjectResponseModel.fromJson(json);
      return model.subjects;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<NotificationModel>> getStudentNotificationsList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      final response = await _dioClient.get(Constants.studentNotificationList,
          options: Options(headers: header));
      var json = _dioClient.getJsonBody(response);
      final model = NotificationResponseModel.fromJson(json);
      return model.notifications;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<VideoModel> addVideo(VideoModel model, {bool isEdit = false}) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};
      final endpoint = isEdit
          ? Constants.crudVideo(model.id)
          : Constants.video;
      await _dioClient.post(endpoint,
          data: data, options: Options(headers: header));
      return model;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<bool> deleteVideo(String videoId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer " + token};

      await _dioClient.delete(
        Constants.crudVideo(videoId),
        options: Options(headers: header),
      );
      return true;
    } catch (error) {
      throw error;
    }
  }
}
