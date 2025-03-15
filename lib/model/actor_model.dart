import 'dart:convert';

import 'package:gyansagar_frontend/helper/enum.dart';

class StudentResponseModel {
  StudentResponseModel({
    required this.students,
  });

  final List<ActorModel> students;

  factory StudentResponseModel.fromRawJson(String str) =>
      StudentResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentResponseModel.fromJson(Map<String, dynamic> json) =>
      StudentResponseModel(
        students: json["students"] == null
            ? []
            : List<ActorModel>.from(
            json["students"].map((x) => ActorModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "students": List<dynamic>.from(students.map((x) => x.toJson())),
  };
}

class ActorModel {
  ActorModel({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.mobile,
    required this.token,
    required this.id,
    required this.isVerified,
    required this.lastLoginDate,
    this.fcmToken,
    this.otpErrorMsg,
    this.otp,
    this.isSelected = false,
  });

  final String name;
  final String email;
  final String password;
  final String role;
  final String mobile;
  String? fcmToken;
  final String token;
  final bool isVerified;
  final DateTime lastLoginDate;
  final String id;
  final int? otp;
  final String? otpErrorMsg;
  bool isSelected;

  factory ActorModel.fromRawJson(String str) =>
      ActorModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActorModel.fromJson(Map<String, dynamic> json) => ActorModel(
    isVerified: json["isVerified"] ?? false,
    lastLoginDate: json["lastLoginDate"] == null
        ? DateTime.now()
        : DateTime.parse(json["lastLoginDate"]),
    id: json["id"] ?? '',
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    password: json["password"] ?? '',
    role: json["role"] ?? '',
    mobile: json["mobile"] ?? '',
    token: json["token"] ?? '',
    fcmToken: json["fcmToken"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "isVerified": isVerified,
    "lastLoginDate": lastLoginDate.toIso8601String(),
    "id": id,
    "name": name,
    "email": email,
    "password": password,
    "role": role,
    "mobile": mobile,
    "token": token,
    "fcmToken": fcmToken,
    "otp": otp,
  };

  Map<String, dynamic> toJson1() => {
    "name": name,
    "mobile": mobile,
    "isSelected": isSelected,
  };

  factory ActorModel.fromError(Map<String, dynamic> json) => ActorModel(
    password: json.containsKey("password") ? json["password"][0] : '',
    email: json.containsKey("email") ? json["email"][0] : '',
    mobile: json.containsKey("mobile") ? json["mobile"][0] : '',
    name: json.containsKey("name") ? json["name"][0] : '',
    otpErrorMsg: json.containsKey("otp") ? json["otp"][0] : null,
    isVerified: json.containsKey("isVerified") ? json["isVerified"][0] : false,
    id: '',
    role: '',
    token: '',
    lastLoginDate: DateTime.now(),
  );

  bool get isStudent => role == Role.STUDENT.asString();
}
