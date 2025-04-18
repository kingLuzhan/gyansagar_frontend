import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BatchTimeSlotModel extends Equatable {
  String day;
  String startTime;
  String endTime;
  int index;
  int dayOfWeek;
  bool isValidStartEntry;
  bool isValidEndEntry;
  String key;

  BatchTimeSlotModel({
    required this.day,
    required this.key,
    required this.startTime,
    required this.endTime,
    required this.index,
    required this.dayOfWeek,
    this.isValidStartEntry = true,
    this.isValidEndEntry = true,
  });

  factory BatchTimeSlotModel.initial() {
    return BatchTimeSlotModel(
      key: UniqueKey().toString(),
      index: 0,
      day: "Mon",
      startTime: "Start time",
      endTime: "End time",
      dayOfWeek: 1, // Monday
    );
  }

  factory BatchTimeSlotModel.fromJson(Map<String, dynamic> json) =>
      BatchTimeSlotModel(
        dayOfWeek: json["dayOfWeek"] ?? 0,
        startTime: json["startTime"]?.replaceAll(" ", "") ?? "Start time",
        endTime: json["endTime"]?.replaceAll(" ", "") ?? "End time",
        day: indexToDay(json["dayOfWeek"] ?? 0),
        key: UniqueKey().toString(),
        index: 0,
      );

  Map<String, dynamic> toJson() => {
    "dayOfWeek": dayOfWeek,
    "startTime": startTime.replaceAll(" ", ""),
    "endTime": endTime.replaceAll(" ", ""),
  };

  static int dayToIndex(String day) {
    switch (day) {
      case "Mon":
        return 1;
      case "Tue":
        return 2;
      case "Wed":
        return 3;
      case "Thu":
        return 4;
      case "Fri":
        return 5;
      case "Sat":
        return 6;
      case "Sun":
        return 7;
      default:
        log("Unknown Day index $day", name: "BatchTimeSlotModel");
        return 0;
    }
  }

  static String indexToDay(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        log("Unknown dayOfWeek $dayOfWeek",
            name: "BatchTimeSlotModel");
        return "N/A";
    }
  }

  String toShortDay() {
    switch (day) {
      case "Monday":
        return "Mon";
      case "Tuesday":
        return "Tue";
      case "Wednesday":
        return "Wed";
      case "Thursday":
        return "Thu";
      case "Friday":
        return "Fri";
      case "Saturday":
        return "Sat";
      case "Sunday":
        return "Sun";
      default:
        log("Unknown day $day", name: "BatchTimeSlotModel");
        return "N/A";
    }
  }

  BatchTimeSlotModel copyWith({
    String? day,
    String? startTime,
    String? endTime,
    int? index,
    int? dayOfWeek,
    bool? isValidStartEntry,
    bool? isValidEndEntry,
    String? key,
  }) {
    return BatchTimeSlotModel(
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      index: index ?? this.index,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isValidStartEntry: isValidStartEntry ?? this.isValidStartEntry,
      isValidEndEntry: isValidEndEntry ?? this.isValidEndEntry,
      key: key ?? this.key,
    );
  }

  @override
  List<Object> get props => [index];
}