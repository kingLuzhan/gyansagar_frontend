import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/create_announcement_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/resources/repository/teacher/teacher_repository.dart';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/states/base_state.dart';

class AnnouncementState extends BaseState {
  final String batchId;
  File? imagefile;
  File? docfile;
  bool isForAll = true;
  List<AnnouncementModel> batchAnnouncementList = [];

  // Used when announcement is in edit mode
  String title = '';
  String description = '';
  final bool isEditMode;

  AnnouncementModel announcementModel;

  AnnouncementState({
    required this.batchId,
    AnnouncementModel? announcementModel, // Make it nullable here
    this.isEditMode = false,
  })  : announcementModel = announcementModel ?? AnnouncementModel(
    id: '',
    title: '',
    description: '',
    isForAll: false,
    image: '',
    file: '',
    batches: [],
    createdAt: DateTime.now(),
    owner: ActorModel(
      id: '',
      name: '',
      email: '',
      password: '',
      role: '',
      mobile: '',
      token: '',
      isVerified: false,
      lastLoginDate: DateTime.now(),
    ),
  );

  set setImageForAnnouncement(File io) {
    imagefile = io;
    docfile = null;
    notifyListeners();
  }

  set setDocForAnnouncement(File io) {
    docfile = io;
    imagefile = null;
    notifyListeners();
  }

  void removeAnnouncementImage() {
    imagefile = null;
    notifyListeners();
  }

  void removeAnnouncementDoc() {
    docfile = null;
    notifyListeners();
  }

  void setIsForAll(bool value) {
    isForAll = value;
    notifyListeners();
  }

  Future<void> getBatchAnnouncementList() async {
    await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      batchAnnouncementList = await repo.getBatchAnnouncementList(batchId);
      batchAnnouncementList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      isBusy = false;
    }, label: "getBatchAnnouncementList");
  }

  Future<AnnouncementModel?> createAnnouncement({
    required String title,
    required String description,
    List<BatchModel>? batches,
  }) async {
    try {
      var model = announcementModel.copyWith(
        batches: batches == null
            ? null
            : batches.where((element) => element.isSelected).map((e) => e.id).toList(),
        description: description,
        isForAll: false,
      );

      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      final data = await repo.createAnnouncement(model, isEdit: isEditMode);

      if (imagefile != null || docfile != null) {
        var ok = await upload(data.id);
        isBusy = false;
        if (ok) {
          return model;
        } else {
          return null;
        }
      }
      return model;
    } catch (error, stackTrace) {
      print("createAnnouncement error: $error, stackTrace: $stackTrace");
      return null;
    }
  }

  Future<bool> upload(String id) async {
    String endpoint = imagefile != null
        ? Constants.uploadImageInAnnouncement(id)
        : Constants.uploadDocInAnnouncement(id);

    return await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<TeacherRepository>();
      bool result = (await repo.uploadFile(imagefile ?? docfile!, id, endpoint: endpoint)) ?? false;
      isBusy = false;
      return result;
    }, label: "Upload Image");
  }

  void onAnnouncementDeleted(AnnouncementModel model) {
    batchAnnouncementList.removeWhere((element) => element.id == model.id);
    notifyListeners();
  }
}