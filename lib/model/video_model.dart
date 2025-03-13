import 'dart:convert';

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String videoUrl;
  final String thumbnailUrl;
  final String batchId;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.batchId,
  });

  factory VideoModel.fromRawJson(String str) => VideoModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json["id"] ?? "",
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    subject: json["subject"] ?? "",
    videoUrl: json["videoUrl"] ?? "",
    thumbnailUrl: json["thumbnailUrl"] ?? "",
    batchId: json["batchId"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "subject": subject,
    "videoUrl": videoUrl,
    "thumbnailUrl": thumbnailUrl,
    "batchId": batchId,
  };

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? videoUrl,
    String? thumbnailUrl,
    String? batchId,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      batchId: batchId ?? this.batchId,
    );
  }
}