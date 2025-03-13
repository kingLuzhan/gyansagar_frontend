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
        required this.title,
        required this.createdAt,
    });

    final String title;
    final DateTime createdAt;

    factory NotificationModel.fromRawJson(String str) =>
        NotificationModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory NotificationModel.fromJson(Map<String, dynamic> json) =>
        NotificationModel(
            title: json["title"] ?? "",
            createdAt: json["createdAt"] != null
                ? DateTime.parse(json["createdAt"])
                : DateTime.now(),
        );

    Map<String, dynamic> toJson() => {
        "title": title,
        "createdAt": createdAt.toIso8601String(),
    };
}
