enum Role { TEACHER, STUDENT }

extension TypeOfSearch on Role {
  String asString() {
    return {
      Role.TEACHER: "teacher",
      Role.STUDENT: "student",
    }[this]!;
  }

  static Role fromString(String value) {
    return {
      "teacher": Role.TEACHER,
      "student": Role.STUDENT,
    }[value] ?? (throw ArgumentError("Invalid role: $value"));
  }
}

enum RawType { VIDEO, MATERIAL, ANNOUNCEMENT }

final typeValues = EnumValues({
  "announcement": RawType.ANNOUNCEMENT,
  "material": RawType.MATERIAL,
  "video": RawType.VIDEO,
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((key, value) => MapEntry(value, key));
  }

  Map<T, String> get reverse => reverseMap;
}
