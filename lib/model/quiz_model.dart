import 'dart:convert';

class QuizResponseModel {
  QuizResponseModel({
    required this.assignments,
  });

  final List<AssignmentModel> assignments;

  factory QuizResponseModel.fromRawJson(String str) =>
      QuizResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuizResponseModel.fromJson(Map<String, dynamic> json) =>
      QuizResponseModel(
        assignments: (json["assignments"] as List?)
            ?.map((x) => AssignmentModel.fromJson(x))
            .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "assignments": assignments.map((x) => x.toJson()).toList(),
  };
}

class AssignmentModel {
  AssignmentModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.owner,
    required this.questions,
  });

  final String id;
  final String title;
  final int duration;
  final String owner;
  final int questions;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
    id: json["id"] ?? '',
    title: json["title"] ?? '',
    duration: json["duration"] ?? 0,
    owner: json["owner"] ?? '',
    questions: json["questions"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "duration": duration,
    "owner": owner,
    "questions": questions,
  };
}

class QuizDetailModel {
  QuizDetailModel({
    required this.title,
    required this.duration,
    required this.owner,
    required this.batch,
    required this.questions,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
  });

  final String title;
  final int duration;
  final String owner;
  final String batch;
  final List<Question> questions;
  final List<QuizResponseModelAnswer> answers;
  final String createdAt;
  final String updatedAt;

  factory QuizDetailModel.fromJson(Map<String, dynamic> json) => QuizDetailModel(
    title: json["title"] ?? '',
    duration: json["duration"] ?? 0,
    owner: json["owner"] ?? '',
    batch: json["batch"] ?? '',
    questions: (json["questions"] as List?)
        ?.map((x) => Question.fromJson(x))
        .toList() ??
        [],
    answers: (json["answers"] as List?)
        ?.map((x) => QuizResponseModelAnswer.fromJson(x))
        .toList() ??
        [],
    createdAt: json["createdAt"] ?? '',
    updatedAt: json["updatedAt"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "duration": duration,
    "owner": owner,
    "batch": batch,
    "questions": questions.map((x) => x.toJson()).toList(),
    "answers": answers.map((x) => x.toJson()).toList(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class QuizResponseModelAnswer {
  QuizResponseModelAnswer({
    required this.student,
    required this.answers,
    required this.correct,
    required this.incorrect,
    required this.skipped,
    required this.timeTaken,
  });

  final String student;
  final List<AnswerAnswer> answers;
  final int correct;
  final int incorrect;
  final int skipped;
  final int timeTaken;

  factory QuizResponseModelAnswer.fromJson(Map<String, dynamic> json) =>
      QuizResponseModelAnswer(
        student: json["student"] ?? '',
        answers: (json["answers"] as List?)
            ?.map((x) => AnswerAnswer.fromJson(x))
            .toList() ??
            [],
        correct: json["correct"] ?? 0,
        incorrect: json["incorrect"] ?? 0,
        skipped: json["skipped"] ?? 0,
        timeTaken: json["timeTaken"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "student": student,
    "answers": answers.map((x) => x.toJson()).toList(),
    "correct": correct,
    "incorrect": incorrect,
    "skipped": skipped,
    "timeTaken": timeTaken,
  };
}

class AnswerAnswer {
  AnswerAnswer({
    required this.question,
    required this.option,
  });

  final String question;
  final String option;

  factory AnswerAnswer.fromJson(Map<String, dynamic> json) => AnswerAnswer(
    question: json["question"] ?? '',
    option: json["option"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "question": question,
    "option": option,
  };
}

class Question {
  Question({
    required this.id,
    required this.statement,
    required this.options,
    required this.answer,
    this.selectedAnswer,
  });

  final String id;
  final String statement;
  final List<String> options;
  final String answer;
  String? selectedAnswer; // ✅ Made nullable

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json["id"] ?? '',
    statement: json["statement"] ?? '',
    options: (json["options"] as List?)?.map((x) => x.toString()).toList() ?? [],
    answer: json["answer"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "statement": statement,
    "options": options,
    "answer": answer,
  };
}
