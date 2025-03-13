import 'dart:developer';
import 'dart:io';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/model/video_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/resources/repository/teacher/teacher_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';

class VideoState extends BaseState {
  VideoState({
    required this.subject,
    required this.batchId,
    this.isEditMode = false,
    required this.videoModel,
  }) {
    thumbnailUrl = videoModel.thumbnailUrl;
    videoUrl = videoModel.videoUrl;
    yTitle = videoModel.title;
    file = File('');
    list = [];
  }

  late String batchId;
  late String videoUrl;
  late String thumbnailUrl;
  late String yTitle;
  late String subject;
  late File file;
  bool isEditMode;
  late VideoModel videoModel;

  /// Container all video list
  late List<VideoModel> list;

  set setFile(File data) {
    file = data;
    notifyListeners();
  }

  void removeFile() {
    file = File('');
    notifyListeners();
  }

  void setUrl({required String videoUrl, required String title, required String thumbnailUrl}) {
    this.videoUrl = videoUrl;
    this.yTitle = title;
    this.thumbnailUrl = thumbnailUrl;
    notifyListeners();
  }

  Future<bool> addVideo(String title, String description) async {
    try {
      var model = videoModel.copyWith(
        title: title,
        description: description,
        subject: subject,
        videoUrl: videoUrl,
        batchId: batchId,
        thumbnailUrl: thumbnailUrl,
      );

      final getit = GetIt.instance;
      final repo = getit.get<TeacherRepository>();

      final data = await execute(() async {
        return await repo.addVideo(model, isEdit: isEditMode);
      }, label: "addVideo");

      /// If video is uploaded
      bool ok = await upload(data!.id);
      isBusy = false;
      return ok;
    } catch (error, stackTrace) {
      log("addVideo", error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Upload video file to server
  Future<bool> upload(String id) async {
    String endpoint = Constants.video + "/$id/upload";
    return await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<TeacherRepository>();
      return await repo.uploadFile(file, id, endpoint: endpoint) ?? false;
    }, label: "Upload Video");
  }

  /// Fetch video list related to a batch from server
  Future getVideosList() async {
    await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      list = await repo.getVideosList(batchId);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      isBusy = false;
    }, label: "getVideosList");
  }

  Future<bool> deleteVideo(String videoId) async {
    try {
      var isDeleted = await deleteById(Constants.crudVideo(videoId));
      if (isDeleted) {
        list.removeWhere((element) => element.id == videoId);
      }
      notifyListeners();
      return isDeleted;
    } catch (error) {
      log("deleteVideo", error: error, name: this.runtimeType.toString());
      return false;
    }
  }
}