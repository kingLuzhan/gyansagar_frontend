import 'dart:convert';

class NotificationResponseModel {
    NotificationResponseModel({required this.notifications});

    final List<NotificationModel> notifications;

    factory NotificationResponseModel.fromRawJson(String str) =>
        NotificationResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
        NotificationResponseModel(
            notifications: (json["notifications"] as List<dynamic>?)
                ?.map((x) => NotificationModel.fromJson(x))
                .toList() ??
                [],
        );

    Map<String, dynamic> toJson() => {
        "notifications": notifications.map((x) => x.toJson()).toList(),
    };
}

class NotificationModel {
    NotificationModel({
        required this.id,
        required this.title,
        required this.body,
        required this.type,
        required this.isRead,
        required this.metadata,
        required this.createdAt,
    });

    final String id;
    final String title;
    final String body;
    final String type;
    final bool isRead;
    final Map<String, dynamic> metadata;
    final DateTime createdAt;

    factory NotificationModel.fromRawJson(String str) =>
        NotificationModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory NotificationModel.fromJson(Map<String, dynamic> json) =>
        NotificationModel(
            id: json["id"] ?? "",
            title: json["title"] ?? "",
            body: json["body"] ?? "",
            type: json["type"] ?? "general",
            isRead: json["isRead"] ?? false,
            metadata: json["metadata"] ?? {},
            createdAt: json["createdAt"] != null
                ? DateTime.parse(json["createdAt"])
                : DateTime.now(),
        );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "type": type,
        "isRead": isRead,
        "metadata": metadata,
        "createdAt": createdAt.toIso8601String(),
    };
}
