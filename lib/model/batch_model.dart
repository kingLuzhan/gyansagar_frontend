import 'dart:convert';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/batch_time_slot_model.dart';

class BatchResponseModel {
  BatchResponseModel({required this.batches});

  final List<BatchModel> batches;

  factory BatchResponseModel.fromRawJson(String str) =>
      BatchResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BatchResponseModel.fromJson(Map<String, dynamic> json) =>
      BatchResponseModel(
        batches: (json["batches"] as List<dynamic>?)
            ?.map((x) => BatchModel.fromJson(x))
            .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "batches": batches.map((x) => x.toJson()).toList(),
  };
}

class BatchModel {
  BatchModel({
    required this.id,
    required this.name,
    required this.description,
    required this.classes,
    required this.subject,
    required this.students,
    required this.studentModel,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String description;
  final List<BatchTimeSlotModel> classes;
  final String subject;
  final List<String> students;
  final List<ActorModel> studentModel;
  bool isSelected;

  factory BatchModel.fromRawJson(String str) =>
      BatchModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  BatchModel copyWith({
    String? id,
    String? name,
    List<BatchTimeSlotModel>? classes,
    String? description,
    bool? isSelected,
    String? subject,
    List<ActorModel>? studentModel,
    List<String>? students,
  }) {
    return BatchModel(
      id: id ?? this.id,
      classes: classes ?? this.classes,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
      name: name ?? this.name,
      studentModel: studentModel ?? this.studentModel,
      students: students ?? this.students,
      subject: subject ?? this.subject,
    );
  }

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    classes: (json["classes"] as List<dynamic>?)
        ?.map((x) => BatchTimeSlotModel.fromJson(x))
        .toList() ??
        [],
    subject: json["subject"] ?? "",
    students: (json["students"] as List<dynamic>?)
        ?.map((x) => x.toString())
        .toList() ??
        [],
    studentModel: (json["studentModel"] as List<dynamic>?)
        ?.map((x) => ActorModel.fromJson(x))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "classes": classes.map((x) => x.toJson()).toList(),
    "subject": subject,
    "students": students.map((x) => x).toList(),
    "studentModel": studentModel.map((x) => x.toJson()).toList(),
  };
}
