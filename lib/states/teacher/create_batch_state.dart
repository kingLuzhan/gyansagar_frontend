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

  BatchModel editBatch = BatchModel(
    id: '',
    name: '',
    description: '',
    classes: [],
    subject: '',
    students: [],
    studentModel: [],
  );

  void setBatchToEdit(BatchModel model) {
    isEditBatch = true;
    editBatch = model;
    batchName = model.name;
    description = model.description;
    var counter = 0;
    timeSlots = List.from(model.classes);
    timeSlots =
        timeSlots.map((clas) {
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
    timeSlots =
        timeSlots.map((element) {
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

  void checkSlotsModel(BatchTimeSlotModel model) {
    BatchTimeSlotModel updatedModel = model;

    // Validate start time
    if (model.startTime == "Start time") {
      updatedModel = model.copyWith(isValidStartEntry: false);
    } else {
      updatedModel = model.copyWith(isValidStartEntry: true);
    }

    // Validate end time
    if (model.endTime == "End time") {
      updatedModel = model.copyWith(isValidEndEntry: false);
    } else {
      updatedModel = model.copyWith(isValidEndEntry: true);
    }

    // Compare start and end times if both are set
    if (model.startTime != "Start time" && model.endTime != "End time") {
      final startParts = model.startTime.split(":");
      final endParts = model.endTime.split(":");

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      if (startHour > endHour ||
          (startHour == endHour && startMinute >= endMinute)) {
        updatedModel = model.copyWith(isValidEndEntry: false);
      }
    }

    // Update the model in timeSlots list
    final index = timeSlots.indexWhere((slot) => slot.key == model.key);
    if (index != -1) {
      timeSlots[index] = updatedModel;
      notifyListeners();
    }
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
    var model = studentsList.firstWhere(
      (e) => e.name == value.name && e.email == value.email,
    );
    model.isSelected = true;
    notifyListeners();
  }

  void removeStudentFromList(ActorModel value) {
    var model = studentsList.firstWhere(
      (e) => e.name == value.name && e.email == value.email,
    );
    model.isSelected = false;
    notifyListeners();
  }

  // Add these inside the class
  List<String> _selectedStudents = [];

  set setSelectedStudents(List<String> value) {
    _selectedStudents = value;
    notifyListeners();
  }

  List<String> get selectedStudents => _selectedStudents;

  Future<BatchModel> createBatch() async {
    try {
      final selectedStudents =
          studentsList
              .where((element) => element.isSelected)
              .map((e) => e.email ?? '')
              .where((email) => email.isNotEmpty)
              .toList();

      if (selectedStudents.isEmpty) {
        throw "Please select at least one student with valid email";
      }

      // Use the existing BatchModel to create a new batch
      final model = BatchModel(
        id: editBatch.id,
        name: batchName,
        description: description,
        classes: timeSlots,
        subject: selectedSubjects,
        students: selectedStudents,
        studentModel:
            studentsList.where((element) => element.isSelected).toList(),
      );

      final repo = getit.get<BatchRepository>();
      return await repo.createBatch(model); // Ensure this returns a BatchModel
    } catch (error, stackTrace) {
      log("createBatch", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future getStudentList() async {
    try {
      final repo = getit.get<TeacherRepository>();
      studentsList = await repo.getStudentList();
      if (studentsList.isNotEmpty) {
        studentsList.removeWhere((element) => element.email == null);
        studentsList = studentsList.toSet().toList();
        final ids = studentsList.map((e) => e.email).toSet();
        studentsList.retainWhere((x) => ids.remove(x.email));
        if (selectedStudentsList.isNotEmpty) {
          for (var student in studentsList) {
            var isAvailable = selectedStudentsList.any(
              (element) => student.id == element.id,
            );
            student.isSelected = isAvailable;
          }
        }
      }

      await getSubjectList();
      notifyListeners();
    } catch (error, stackTrace) {
      log("getStudentList", error: error, stackTrace: stackTrace);
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

      availableSubjects =
          Iterable.generate(
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

  bool checkSlotsValidations() {
    bool allGood = true;
    for (var model in timeSlots) {
      checkSlotsModel(model);
    }
    notifyListeners();
    return timeSlots.every(
      (element) => element.isValidEndEntry && element.isValidStartEntry,
    );
  }

  void addNewSubject(String value) {
    availableSubjects.add(
      Subject(index: availableSubjects.length, name: value, isSelected: false),
    );
    notifyListeners();
  }
}
