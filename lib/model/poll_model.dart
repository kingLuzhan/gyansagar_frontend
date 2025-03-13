import 'dart:convert';

import 'package:gyansagar_frontend/helper/utility.dart';

class PollResponseModel {
  PollResponseModel({required this.polls});

  final List<PollModel> polls;

  factory PollResponseModel.fromRawJson(String str) =>
      PollResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PollResponseModel.fromJson(Map<String, dynamic> json) =>
      PollResponseModel(
        polls: (json["polls"] as List<dynamic>?)
            ?.map((x) => PollModel.fromJson(x))
            .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "polls": polls.map((x) => x.toJson()).toList(),
  };
}

class PollModel {
  PollModel({
    required this.id,
    required this.question,
    required this.options,
    required this.endTime,
    required this.batches,
    required this.isForAll,
    required this.answers,
    required this.totalVotes,
    required this.votes,
    required this.createdAt,
    required this.updatedAt,
    this.selection,
  });

  final String id;
  final String question;
  final List<String> options;
  final DateTime endTime;
  final List<dynamic> batches;
  final bool isForAll;
  final List<Answer> answers;
  final int totalVotes;
  final Map<String, double> votes;
  final DateTime createdAt;
  final DateTime updatedAt;
  MySelection? selection;

  PollModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    DateTime? endTime,
    List<dynamic>? batches,
    bool? isForAll,
    List<Answer>? answers,
    int? totalVotes,
    Map<String, double>? votes,
    DateTime? createdAt,
    DateTime? updatedAt,
    MySelection? selection,
  }) =>
      PollModel(
        id: id ?? this.id,
        question: question ?? this.question,
        options: options ?? this.options,
        endTime: endTime ?? this.endTime,
        batches: batches ?? this.batches,
        isForAll: isForAll ?? this.isForAll,
        answers: answers ?? this.answers,
        totalVotes: totalVotes ?? this.totalVotes,
        votes: votes ?? this.votes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        selection: selection ?? this.selection,
      );

  factory PollModel.fromRawJson(String str) =>
      PollModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PollModel.fromJson(Map<String, dynamic> json) => PollModel(
    id: json["id"] ?? "",
    question: json["question"] ?? "",
    totalVotes: json["totalVotes"] ?? 0,
    options: (json["options"] as List<dynamic>?)
        ?.map((x) => x.toString())
        .toList() ??
        [],
    endTime: json["endTime"] != null
        ? DateTime.parse(json["endTime"])
        : DateTime.now(),
    batches: json["batches"] ?? [],
    isForAll: json["isForAll"] ?? false,
    answers: (json["answers"] as List<dynamic>?)
        ?.map((x) => Answer.fromJson(x))
        .toList() ??
        [],
    votes: json["votes"] != null
        ? Map<String, double>.from(
        json["votes"].map((k, v) => MapEntry(k, v.toDouble())))
        : {},
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : DateTime.now(),
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : DateTime.now(),
    selection: json["selection"] != null ? MySelection.fromJson(json["selection"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "options": options,
    "endTime": Utility.toFormattedDate3(endTime),
    "batches": batches,
    "isForAll": isForAll,
    "answers": answers.map((x) => x.toJson()).toList(),
    "totalVotes": totalVotes,
    "votes": votes.map((k, v) => MapEntry(k, v)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "selection": selection?.toJson(),
  };

  double percent(String key) {
    final total = voteOnOption(key);
    if (total == 0) {
      return 0;
    }
    return (total * 100);
  }

  double voteOnOption(String key) {
    return votes[key] ?? 0;
  }

  bool isMyVote(String studentId, String option) {
    return answers.any(
            (element) => element.studentId == studentId && element.option == option);
  }

  bool isVoted(String userId) {
    return answers.any((element) => element.studentId == userId);
  }
}

class Answer {
  Answer({
    required this.studentId,
    required this.option,
  });

  final String studentId;
  final String option;

  Answer copyWith({
    String? studentId,
    String? option,
  }) =>
      Answer(
        studentId: studentId ?? this.studentId,
        option: option ?? this.option,
      );

  factory Answer.fromRawJson(String str) => Answer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    studentId: json["studentId"] ?? "",
    option: json["option"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "studentId": studentId,
    "option": option,
  };
}

class MySelection {
  final bool isSelected;
  final String choice;
  bool loading;

  MySelection({this.choice = "", this.isSelected = false, this.loading = false});

  factory MySelection.fromJson(Map<String, dynamic> json) => MySelection(
    choice: json["choice"] ?? "",
    isSelected: json["isSelected"] ?? false,
    loading: json["loading"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "choice": choice,
    "isSelected": isSelected,
    "loading": loading,
  };
}
