import 'dart:io';

import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/session/session.dart';

class TeacherRepository {
  final ApiGateway gateway;
  final SessionService sessionService;
  final SharedPreferenceHelper pref;

  TeacherRepository(this.gateway, this.sessionService, this.pref);

  Future<List<String>> getSubjectList() async {
    return gateway.getSubjectList();
  }

  Future<List<ActorModel>> getStudentList() async {
    return gateway.getStudentList();
  }

  Future<bool> createPoll(PollModel model) async {
    return gateway.createPoll(model);
  }

  Future<bool> expirePollById(String pollId) {
    return gateway.expirePollById(pollId);
  }

  Future<VideoModel> addVideo(VideoModel model, {bool isEdit = false}) {
    return gateway.addVideo(model, isEdit: isEdit);
  }

  Future<bool> uploadFile(File file, String id, {String? endpoint}) async {
    try {
      // Assuming the method in ApiGateway returns a boolean indicating success
      bool success = await gateway.uploadFile(file, id, endpoint: endpoint);
      return success;
    } catch (error) {
      // Handle error and return false
      return false;
    }
  }

  Future<BatchMaterialModel> uploadMaterial(BatchMaterialModel model, {bool isEdit = false}) {
    return gateway.uploadMaterial(model, isEdit: isEdit);
  }
}