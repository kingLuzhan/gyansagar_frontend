import 'dart:io';

import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/model/poll_model.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/session/session.dart';

class TeacherRepository {
  final ApiGateway gatway;
  final SessionService sessionService;
  final SharedPreferenceHelper pref;

  TeacherRepository(this.gatway, this.sessionService, this.pref);

  Future<List<String>> getSubjectList() async {
    return gatway.getSubjectList();
  }

  Future<List<ActorModel>> getStudentList() async {
    return gatway.getStudentList();
  }

  Future<bool> createPoll(PollModel model) async {
    return gatway.createPoll(model);
  }

  Future<bool> expirePollById(String pollId) {
    return gatway.expirePollById(pollId);
  }

  Future<VideoModel> addVideo(VideoModel model, {bool isEdit = false}) {
    return gatway.addVideo(model, isEdit: isEdit);
  }

  Future<bool> uploadFile(File file, String id, {String endpoint = ''}) {
    return gatway.uploadFile(file, id, endpoint: endpoint);
  }

  Future<BatchMaterialModel> uploadMaterial(BatchMaterialModel model, {bool isEdit = false}) {
    return gatway.uploadMaterial(model, isEdit: isEdit);
  }
}