import 'dart:convert';

class SubjectResponseModel {
  SubjectResponseModel({
    required this.subjects,
  });

  final List<String> subjects;

  SubjectResponseModel copyWith({
    List<String>? subjects,
  }) =>
      SubjectResponseModel(
        subjects: subjects ?? this.subjects,
      );

  factory SubjectResponseModel.fromRawJson(String str) => SubjectResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SubjectResponseModel.fromJson(Map<String, dynamic> json) => SubjectResponseModel(
    subjects: (json["subjects"] as List?)?.map((x) => x.toString()).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    "subjects": subjects.map((x) => x).toList(),
  };
}

class Subject {
  final String name;
  final int index;
  bool isSelected;

  Subject({
    required this.name,
    required this.index,
    this.isSelected = false,
  });

  Subject copyWith({
    String? name,
    int? index,
    bool? isSelected,
  }) =>
      Subject(
        name: name ?? this.name,
        index: index ?? this.index,
        isSelected: isSelected ?? this.isSelected,
      );
}
