import 'dart:developer';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_model.dart';
import 'package:gyansagar_frontend/model/batch_time_slot_model.dart';
import 'package:gyansagar_frontend/model/subject.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/resources/repository/teacher/teacher_repository.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateBatchStates extends BaseState {
  CreateBatchStates(BatchModel model) {
    setBatchToEdit(model);
  }

  @override
  final getit = GetIt.instance;
  String batchName = "";
  String description = "";
  bool isEditBatch = false;
  String selectedSubjects = "";

  BatchModel editBatch = BatchModel(id: '', name: '', description: '', classes: [], subject: '', students: [], studentModel: []);

  void setBatchToEdit(BatchModel model) {
    isEditBatch = true;
    editBatch = model;
    batchName = model.name;
    description = model.description;
    var counter = 0;
    timeSlots = List.from(model.classes);
    timeSlots = timeSlots.map((clas) {
      return clas.copyWith(index: counter++, key: UniqueKey().toString());
    }).toList();

    selectedSubjects = model.subject;
    selectedStudentsList = model.studentModel;
  }

  List<Subject> availableSubjects = [];
  List<String> contactList = [];
  List<String> deviceSelectedContacts = [];
  List<BatchTimeSlotModel> timeSlots = [BatchTimeSlotModel.initial()];
  List<ActorModel> studentsList = [];
  List<ActorModel> selectedStudentsList = [];

  set setBatchName(String value) {
    batchName = value;
  }

  set setBatchdescription(String value) {
    description = value;
  }

  void setTimeSlots(BatchTimeSlotModel model) {
    model = model.copyWith(index: timeSlots.length);
    timeSlots.add(model);
    notifyListeners();
  }

  bool removeTimeSlot(BatchTimeSlotModel model) {
    timeSlots.removeWhere((element) => element.key == model.key);
    timeSlots = timeSlots.map((element) {
      return element.copyWith(index: timeSlots.indexOf(element));
    }).toList();
    notifyListeners();
    return true;
  }

  set setSelectedSubjects(String name) {
    var model = availableSubjects.firstWhere((element) => element.name == name);
    for (var element in availableSubjects) {
      element.isSelected = false;
    }
    model.isSelected = true;
    selectedSubjects = name;
    notifyListeners();
  }

  void updateTimeSlots(BatchTimeSlotModel model, int index) {
    timeSlots[index] = model;
    checkSlotsModel(model);
    notifyListeners();
  }

  void addContact(String mobile) {
    contactList.add(mobile);
    notifyListeners();
  }

  void removeContact(String mobile) {
    contactList.remove(mobile);
    notifyListeners();
  }

  set setStudentsFromList(ActorModel value) {
    var model = studentsList
        .firstWhere((e) => e.name == value.name && e.mobile == value.mobile);
    model.isSelected = true;
    notifyListeners();
  }

  void removeStudentFromList(ActorModel value) {
    var model = studentsList
        .firstWhere((e) => e.name == value.name && e.mobile == value.mobile);
    model.isSelected = false;
    notifyListeners();
  }

  void addNewSubject(String value) {
    availableSubjects.add(Subject(
        index: availableSubjects.length, name: value, isSelected: false));
    notifyListeners();
  }

  Future<void> fetchContacts() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
      if (!status.isGranted) {
        // Handle the case where the user denied the permission
        return;
      }
    }

    try {
      List<Contact> contacts = await FastContacts.getAllContacts();
      setDeviceSelectedContacts(contacts);
    } catch (e) {
      // Handle error
      print("Error fetching contacts: $e");
    }
  }

  void setDeviceSelectedContacts(List<Contact> list) {
    deviceSelectedContacts =
        list.map((e) => e.phones.isNotEmpty ? e.phones.first.number.replaceAll(" ", "") : "").toList();
    notifyListeners();
  }

  bool checkSlotsValidations() {
    bool allGood = true;
    for (var model in timeSlots) {
      checkSlotsModel(model);
    }
    notifyListeners();
    return timeSlots.every(
            (element) => element.isValidEndEntry && element.isValidStartEntry);
  }

  void checkSlotsModel(BatchTimeSlotModel model) {
    if (model.startTime == "Start time") {
      model = model.copyWith(isValidStartEntry: false);
    } else {
      model = model.copyWith(isValidStartEntry: true);
    }
    if (model.endTime == "End time") {
      model = model.copyWith(isValidEndEntry: false);
    } else {
      model = model.copyWith(isValidEndEntry: true);
    }

    if (model.startTime != "Start time" && model.endTime != "End time") {
      if (int.parse(model.startTime.split(":")[0]) >
          int.parse(model.endTime.split(":")[0])) {
        model = model.copyWith(isValidEndEntry: false);
      }

      if (int.parse(model.startTime.split(":")[0]) ==
          int.parse(model.endTime.split(":")[0])) {
        if (int.parse(model.startTime.split(":")[1]) >=
            int.parse(model.endTime.split(":")[1])) {
          model = model.copyWith(isValidEndEntry: false);
        }
      }
    }
  }

  Future<BatchModel> createBatch() async {
    try {
      final mobile = studentsList
          .where((element) => element.isSelected)
          .map((e) => e.mobile);
      List<String> contacts = List.from(contactList)
        ..addAll(mobile)
        ..addAll(deviceSelectedContacts);
      final model = editBatch.copyWith(
          name: batchName,
          description: description,
          classes: timeSlots,
          subject: selectedSubjects,
          students: contacts);
      final repo = getit.get<BatchRepository>();
      await repo.createBatch(model);
      return model;
    } catch (error, strackTrace) {
      log("createBatch", error: error, stackTrace: strackTrace);
      rethrow;
    }
  }

  Future getStudentList() async {
    try {
      final repo = getit.get<TeacherRepository>();
      studentsList = await repo.getStudentList();
      if (studentsList.isNotEmpty) {
        studentsList.removeWhere((element) => element.mobile == null);
        studentsList = studentsList.toSet().toList();
        final ids = studentsList.map((e) => e.mobile).toSet();
        studentsList.retainWhere((x) => ids.remove(x.mobile));
        if (selectedStudentsList.isNotEmpty) {
          for (var student in studentsList) {
            var isAvailable =
            selectedStudentsList.any((element) => student.id == element.id);
            student.isSelected = isAvailable;
          }
        }
      }

      await getSubjectList();
      notifyListeners();
    } catch (error, strackTrace) {
      log("getStudentList", error: error, stackTrace: strackTrace);
      return null;
    }
  }

  Future getSubjectList() async {
    await execute(() async {
      final repo = getit.get<TeacherRepository>();
      final list = await repo.getSubjectList();
      list.toSet().toList();
      final ids = list.map((e) => e).toSet();
      list.retainWhere((x) => ids.remove(x));

      availableSubjects = Iterable.generate(
        list.length,
            (index) => Subject(
          index: index,
          name: list[index],
          isSelected: selectedSubjects == list[index],
        ),
      ).toList();

      if (selectedSubjects.isEmpty && availableSubjects.isNotEmpty) {
        selectedSubjects = availableSubjects.first.name;
      }
    }, label: "Get Subjects");
  }
}