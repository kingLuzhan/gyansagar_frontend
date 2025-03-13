import 'dart:convert';

class BatchMaterialModel {
  final String id;
  final String fileUrl;
  final String title;
  final String subject;
  final String description;
  final String batchId;
  final String filePath;
  final bool isPrivate;
  final String fileUploadedOn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fileType;
  final String? articleUrl;  // Added articleUrl property

  BatchMaterialModel({
    required this.id,
    required this.fileUrl,
    required this.title,
    required this.subject,
    required this.description,
    required this.batchId,
    required this.filePath,
    required this.isPrivate,
    required this.fileUploadedOn,
    required this.createdAt,
    required this.updatedAt,
    this.fileType,
    this.articleUrl,  // Added articleUrl parameter
  });

  factory BatchMaterialModel.fromRawJson(String str) => BatchMaterialModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BatchMaterialModel.fromJson(Map<String, dynamic> json) {
    String? extractedFileType;
    if (json["file"] != null) {
      final parts = json["file"].split(".");
      extractedFileType = parts.isNotEmpty ? parts.last : null;
    }

    return BatchMaterialModel(
      id: json["id"] ?? "",
      fileUrl: json["fileUrl"] ?? "",
      title: json["title"] ?? "",
      subject: json["subject"] ?? "",
      description: json["description"] ?? "",
      batchId: json["batchId"] ?? "",
      filePath: json["file"] ?? "",
      fileType: extractedFileType,
      isPrivate: json["isPrivate"] ?? false,
      fileUploadedOn: json["fileUploadedOn"] ?? "",
      createdAt: _parseDate(json["createdAt"]),
      updatedAt: _parseDate(json["updatedAt"]),
      articleUrl: json["articleUrl"] ?? "",  // Added articleUrl mapping
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "fileUrl": fileUrl,
    "title": title,
    "subject": subject,
    "description": description,
    "batchId": batchId,
    "file": filePath,
    "fileType": fileType,
    "isPrivate": isPrivate,
    "fileUploadedOn": fileUploadedOn,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "articleUrl": articleUrl,  // Added articleUrl to JSON
  };

  BatchMaterialModel copyWith({
    String? id,
    String? fileUrl,
    String? title,
    String? subject,
    String? description,
    String? batchId,
    String? filePath,
    String? fileType,
    bool? isPrivate,
    String? fileUploadedOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? articleUrl,  // Added articleUrl parameter
  }) {
    return BatchMaterialModel(
      id: id ?? this.id,
      fileUrl: fileUrl ?? this.fileUrl,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      batchId: batchId ?? this.batchId,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      isPrivate: isPrivate ?? this.isPrivate,
      fileUploadedOn: fileUploadedOn ?? this.fileUploadedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      articleUrl: articleUrl ?? this.articleUrl,  // Added articleUrl assignment
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null || date.toString().isEmpty) {
      return DateTime(1970, 1, 1);
    }
    return DateTime.tryParse(date.toString()) ?? DateTime(1970, 1, 1);
  }
}