import 'dart:io';
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
import 'package:gyansagar_frontend/model/quiz_model.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/dio_client.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/resources/service/notification_service.dart';
import 'package:get_it/get_it.dart';

class ApiGatewayImpl implements ApiGateway {
  final DioClient _dioClient;
  final SharedPreferenceHelper pref;

  ApiGatewayImpl(this._dioClient, {required this.pref});

  @override
  Future getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<PollModel> castVoteOnPoll(String pollId, String vote) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      final data = {
        "answer": vote, // Changed from "option" to "answer"
      };

      final endpoint = Constants.castStudentVoteOnPoll(pollId);
      var response = await _dioClient.post(
        endpoint,
        data: data,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      if (json.containsKey("poll")) {
        return PollModel.fromJson(json["poll"]);
      }

      throw Exception("Failed to cast vote: Invalid response format");
    } catch (error) {
      print("Error casting vote on poll: $error");
      rethrow;
    }
  }

  @override
  Future<QuizDetailModel> getAssignmentDetailList(
    String batchId,
    String assignmentId,
  ) {
    // TODO: implement getAssignmentDetailList
    throw UnimplementedError();
  }

  @override
  Future<List<AnnouncementModel>> getBatchAnnouncementList(
    String batchId,
  ) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      final response = await _dioClient.get(
        Constants.getBatchAnnouncementList(batchId),
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      List<dynamic> announcementList = json["announcements"] ?? [];

      return announcementList
          .map((announcement) => AnnouncementModel.fromJson(announcement))
          .toList();
    } catch (error) {
      print("Error fetching batch announcements: $error");
      return [];
    }
  }

  @override
  Future<List<VideoModel>> getVideosList(String batchId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      final endpoint = Constants.getBatchVideoList(batchId);
      final response = await _dioClient.get(
        endpoint,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      List<dynamic> videoList = json["videos"] ?? [];

      // Print a sample video to debug
      if (videoList.isNotEmpty) {
        print("Sample video from API: ${videoList[0]}");
      }

      return videoList.map((video) => VideoModel.fromJson(video)).toList();
    } catch (error) {
      print("Error fetching videos: $error");
      return [];
    }
  }

  @override
  Future<bool> uploadFile(File file, String id, {String? endpoint}) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
        "id": id,
      });

      final uploadEndpoint = endpoint ?? Constants.defaultUploadEndpoint;
      var response = await _dioClient.post(
        uploadEndpoint,
        data: formData,
        options: Options(headers: header),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("File upload error: $e");
      return false;
    }
  }

  @override
  Future<BatchMaterialModel> uploadMaterial(
    BatchMaterialModel model, {
    bool isEdit = false,
  }) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      // Create form data for the request
      var formData = FormData();

      // Add model data to form
      formData.fields.add(MapEntry('title', model.title));
      formData.fields.add(MapEntry('description', model.description));
      formData.fields.add(MapEntry('subject', model.subject));
      formData.fields.add(MapEntry('batchId', model.batchId));
      formData.fields.add(MapEntry('isPrivate', model.isPrivate.toString()));

      // Add article URL if available
      if (model.articleUrl != null && model.articleUrl!.isNotEmpty) {
        formData.fields.add(MapEntry('articleUrl', model.articleUrl!));
      }

      // Add file if model has a file path
      if (model.filePath.isNotEmpty) {
        File file = File(model.filePath);
        if (file.existsSync()) {
          String fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              'file',
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      // Determine endpoint based on whether it's an edit or create operation
      final endpoint =
          isEdit ? Constants.crudMaterial(model.id) : Constants.material;

      var response = await _dioClient.post(
        endpoint,
        data: formData,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      if (json.containsKey('material')) {
        return BatchMaterialModel.fromJson(json['material']);
      }

      return model;
    } catch (error) {
      print("Error uploading material: $error");
      rethrow;
    }
  }

  @override
  Future<List<BatchMaterialModel>> getBatchMaterialList(String batchId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final endpoint = Constants.getBatchMaterialList(batchId);

      final response = await _dioClient.get(
        endpoint,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      if (json.containsKey('materials')) {
        List<dynamic> materials = json['materials'];
        return materials
            .map((item) => BatchMaterialModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (error) {
      print("Error fetching batch materials: $error");
      rethrow;
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignmentList(String batchId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      bool isStudent = await pref.isStudent();
      final endpoint = Constants.getBatchAssignmentList(batchId, isStudent);

      final response = await _dioClient.get(
        endpoint,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      if (json.containsKey('assignments')) {
        List<dynamic> assignments = json['assignments'];
        return assignments
            .map((item) => AssignmentModel.fromJson(item))
            .toList();
      }

      return [];
    } catch (error) {
      print("Error fetching assignments: $error");
      rethrow;
    }
  }

  @override
  Future<BatchModel> createBatch(BatchModel model) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      var endpoint =
          model.id == null
              ? Constants.batch
              : Constants.editBatchDetail(model.id);
      var response = await _dioClient.post(
        endpoint,
        data: data,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      if (json.containsKey('batch')) {
        return BatchModel.fromJson(json['batch']);
      }

      throw Exception('Failed to create batch: Invalid response format');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<AnnouncementModel> createAnnouncement(
    AnnouncementModel model, {
    bool isEdit = false,
  }) async {
    try {
      final mapJson = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final endpoint =
          isEdit
              ? Constants.crudAnnouncement(model.id)
              : Constants.announcement;
      var response = await _dioClient.post(
        endpoint,
        data: mapJson,
        options: Options(headers: header),
      );
      final map = _dioClient.getJsonBody(response);
      final data = AnnouncementModel.fromJson(map["announcement"]);
      return data;
    } catch (error) {
      rethrow;
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
      var response = await _dioClient.post(Constants.login, data: data);
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> register(ActorModel model) async {
    try {
      final getit = GetIt.instance<NotificationService>();
      final fcmToken = await getit.getDeviceToken();
      model.fcmToken = fcmToken;
      final data = model.toJson();
      var response = await _dioClient.post(Constants.register, data: data);

      return true;
    } catch (error) {
      rethrow;
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
      rethrow;
    }
  }

  @override
  Future<ActorModel> verifyOtp(ActorModel model) async {
    try {
      final data = model.toJson();
      data.removeWhere((key, value) => value == null);
      var response = await _dioClient.post(Constants.verifyOtp, data: data);
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<ActorModel> updateUser(ActorModel model) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
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
      rethrow;
    }
  }

  @override
  Future<ActorModel> loginWithGoogle(String token) async {
    try {
      final header = {"Authorization": "Bearer $token"};
      var response = await _dioClient.get(
        Constants.googleAuth,
        options: Options(headers: header),
      );
      var map = _dioClient.getJsonBody(response);
      var actor = ActorModel.fromJson(map["user"]);
      return actor;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<BatchModel>> getBatches() async {
    try {
      var token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      bool isStudent = await pref.isStudent();
      var response = await _dioClient.get(
        Constants.getMyBatches(isStudent),
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final list = BatchResponseModel.fromJson(json);
      return list.batches;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<BatchModel> getBatchDetails(String batchId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      
      print("ApiGateway: Fetching batch details for ID: $batchId");
      var response = await _dioClient.get(
        Constants.getBatchDetails(batchId),
        options: Options(headers: header),
      );
      
      var json = _dioClient.getJsonBody(response);
      print("ApiGateway: Raw response: $json");
      
      if (json.containsKey('batch')) {
        var batchData = json['batch'];
        print("ApiGateway: Student data in response: ${batchData['studentModel']}");
        var batch = BatchModel.fromJson(batchData);
        print("ApiGateway: Parsed batch students: ${batch.studentModel.length}");
        return batch;
      }
      
      throw Exception('Failed to get batch details: Invalid response format');
    } catch (error) {
      print("Error fetching batch details: $error");
      rethrow;
    }
  }

  @override
  Future<bool> deleteBatch(String typeAndId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      await _dioClient.delete(typeAndId, options: Options(headers: header));
      return true;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> createPoll(PollModel model) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      await _dioClient.post(
        Constants.poll,
        data: data,
        options: Options(headers: header),
      );
      return true;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool> expirePollById(String pollId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      await _dioClient.post(
        "${Constants.crudePoll(pollId)}/end",
        options: Options(headers: header),
      );
      return true;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncementList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      bool isStudent = await pref.isStudent();

      final response = await _dioClient.get(
        Constants.getMyAnnouncement(isStudent),
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final model = AnnouncementListResponse.fromJson(json);
      return model.announcements;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<BatchTimeline>> getBatchDetailTimeLine(String batchId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      bool isStudent = await pref.isStudent();

      final response = await _dioClient.get(
        Constants.getMyBatchDetailTimeLine(isStudent, batchId),
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);

      if (!json.containsKey('timeline')) {
        return [];
      }

      List<dynamic> timelineData = json['timeline'];
      return timelineData.map((item) {
        // Properly handle different timeline item types
        switch (item['type']?.toLowerCase()) {
          case 'announcement':
            return BatchTimeline.fromJson(item);
          case 'video':
            return BatchTimeline.fromJson(item);
          default:
            print('Unhandled timeline type: ${item['type']}');
            return BatchTimeline.fromJson(item);
        }
      }).toList();
    } catch (error) {
      print("Error fetching batch timeline: $error");
      rethrow;
    }
  }

  @override
  Future<List<PollModel>> getPollList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      String endpoint =
          await pref.isStudent() ? Constants.studentPolls : Constants.poll;
      final response = await _dioClient.get(
        endpoint,
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final model = PollResponseModel.fromJson(json);
      return model.polls;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<ActorModel>> getStudentList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final response = await _dioClient.get(
        Constants.getAllStudentList,
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final model = StudentResponseModel.fromJson(json);
      return model.students;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getSubjectList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final response = await _dioClient.get(
        Constants.subjects,
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final model = SubjectResponseModel.fromJson(json);
      return model.subjects;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<NotificationModel>> getStudentNotificationsList() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final response = await _dioClient.get(
        Constants.studentNotificationList,
        options: Options(headers: header),
      );
      var json = _dioClient.getJsonBody(response);
      final model = NotificationResponseModel.fromJson(json);
      return model.notifications;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<VideoModel> addVideo(VideoModel model, {bool isEdit = false}) async {
    try {
      final data = model.toJson();
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final endpoint =
          isEdit ? Constants.crudVideo(model.id ?? '') : Constants.video;

      var response = await _dioClient.post(
        endpoint,
        data: data,
        options: Options(headers: header),
      );

      // Extract the video object from the response
      var json = _dioClient.getJsonBody(response);
      if (json.containsKey("video")) {
        // Create a new VideoModel from the response
        return VideoModel.fromJson(json["video"]);
      }

      return model; // Return original model if no video in response
    } catch (error) {
      print("Error adding video: $error");
      rethrow;
    }
  }

  @override
  Future<bool> deleteVideo(String videoId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      await _dioClient.delete(
        Constants.crudVideo(videoId),
        options: Options(headers: header),
      );
      return true;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> savePollSelection(PollModel poll) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final endpoint = Constants.crudePoll(poll.id);

      var response = await _dioClient.post(
        endpoint,
        data: poll.toJson(),
        options: Options(headers: header),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save poll selection');
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> expirePoll(String pollId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      // Change from "/expire" to "/end" to match the server endpoint
      final endpoint = "${Constants.crudePoll(pollId)}/end";

      var response = await _dioClient.post(
        endpoint,
        options: Options(headers: header),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to expire poll');
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> deletePoll(String pollId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};
      final endpoint = Constants.crudePoll(pollId);

      var response = await _dioClient.delete(
        endpoint,
        options: Options(headers: header),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete poll');
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      final response = await _dioClient.get(
        Constants.studentNotificationUnreadCount,
        options: Options(headers: header),
      );

      var json = _dioClient.getJsonBody(response);
      return json["count"] ?? 0;
    } catch (error) {
      print("Error getting unread notification count: $error");
      return 0;
    }
  }

  @override
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      final response = await _dioClient.post(
        Constants.markNotificationAsRead(notificationId),
        options: Options(headers: header),
      );

      return response.statusCode == 200;
    } catch (error) {
      print("Error marking notification as read: $error");
      return false;
    }
  }

  @override
  Future<bool> markAllNotificationsAsRead() async {
    try {
      String token = await pref.getAccessToken() ?? '';
      final header = {"Authorization": "Bearer $token"};

      final response = await _dioClient.post(
        Constants
            .studentMarkAllNotificationsAsRead, // Use the constant string instead
        options: Options(headers: header),
      );

      return response.statusCode == 200;
    } catch (error) {
      print("Error marking all notifications as read: $error");
      return false;
    }
  }
}
