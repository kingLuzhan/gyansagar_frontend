import 'dart:convert';
import 'package:gyansagar_frontend/model/actor_model.dart';

class AnnouncementListResponse {
  AnnouncementListResponse({required this.announcements});

  final List<AnnouncementModel> announcements;

  factory AnnouncementListResponse.fromRawJson(String str) =>
      AnnouncementListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AnnouncementListResponse.fromJson(Map<String, dynamic> json) =>
      AnnouncementListResponse(
        announcements: (json["announcements"] as List<dynamic>?)
            ?.map((x) => AnnouncementModel.fromJson(x))
            .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "announcements": announcements.map((x) => x.toJson()).toList(),
  };
}

class AnnouncementModel {
  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isForAll,
    required this.image,
    required this.file,
    required this.batches,
    required this.createdAt,
    required this.owner,
  });

  final String id;
  final String description;
  final String title;
  final bool isForAll;
  final String image;
  final String file;
  final List<String> batches;
  final DateTime createdAt;
  final ActorModel owner;

  factory AnnouncementModel.fromRawJson(String str) =>
      AnnouncementModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      AnnouncementModel(
        id: json["id"] ?? "",
        description: json["description"] ?? "",
        title: json["title"] ?? "",
        image: json["image"] ?? "",
        file: json["file"] ?? "",
        isForAll: json["isForAll"] ?? false,
        batches: (json["batches"] as List<dynamic>?)
            ?.map((x) => x.toString())
            .toList() ??
            [],
        owner: ActorModel.fromJson(json["owner"] ?? {}),
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image,
    "file": file,
    "description": description,
    "isForAll": isForAll,
    "batches": batches,
    "owner": owner.toJson(),
    "createdAt": createdAt.toIso8601String(),
  };

  AnnouncementModel copyWith({
    List<String>? batches,
    String? description,
    String? title,
    String? image,
    String? file,
    bool? isForAll,
    ActorModel? owner,
    DateTime? createdAt,
    String? id,
  }) =>
      AnnouncementModel(
        batches: batches ?? this.batches,
        description: description ?? this.description,
        image: image ?? this.image,
        file: file ?? this.file,
        isForAll: isForAll ?? this.isForAll,
        owner: owner ?? this.owner,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        id: id ?? this.id,
      );
}