import 'dart:developer';
import 'dart:io';
import 'package:gyansagar_frontend/helper/constants.dart';
import 'package:gyansagar_frontend/model/batch_material_model.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/resources/repository/teacher/teacher_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';

class BatchMaterialState extends BaseState {
  BatchMaterialState({
    required this.subject,
    required this.batchId,
    required this.materialModel,
    this.isEditMode = false,
  }) {
    articleUrl = '';
    fileUrl = '';
    title = '';
    file = File('');
    list = [];
  }

  String batchId;
  late String articleUrl;
  late String fileUrl;
  late String title;
  String subject;
  late File file;
  bool isEditMode;
  BatchMaterialModel materialModel;

  /// Container all video list
  late List<BatchMaterialModel> list;

  void setArticleUrl(String url) {
    articleUrl = url;
  }

  set setFile(File data) {
    file = data;
    notifyListeners();
  }

  void removeFile() {
    file = File('');
    notifyListeners();
  }

  Future<bool> uploadMaterial(String title, String description) async {
    final data = await execute(() async {
      var model = materialModel.copyWith(
        title: title,
        description: description,
        subject: subject,
        batchId: batchId,
        fileUrl: fileUrl,
      );
      final getit = GetIt.instance;
      final repo = getit.get<TeacherRepository>();
      return await repo.uploadMaterial(model, isEdit: isEditMode);
    }, label: "uploadMaterial");

    /// If received data from api and we have material to upload
    if (file.path.isNotEmpty) {
      await upload(data!.id);
    }
    isBusy = false;
    return data != null;
  }

  Future<bool> upload(String id) async {
    String endpoint = Constants.material + "/$id/upload";
    return await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<TeacherRepository>();
      return await repo.uploadFile(file, id, endpoint: endpoint) ?? false;
    }, label: "Upload File");
  }

  Future getBatchMaterialList() async {
    await execute(() async {
      isBusy = true;
      final getit = GetIt.instance;
      final repo = getit.get<BatchRepository>();
      list = await repo.getBatchMaterialList(batchId);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      isBusy = false;
    }, label: "getBatchMaterialList");
  }

  Future deleteMaterial(String id) async {
    try {
      var isDeleted = await deleteById(Constants.crudMaterial(id));
      if (isDeleted) {
        list.removeWhere((element) => element.id == id);
      }
      notifyListeners();
      return isDeleted;
    } catch (error) {
      log("deleteMaterial", error: error, name: this.runtimeType.toString());
      return false;
    }
  }
}