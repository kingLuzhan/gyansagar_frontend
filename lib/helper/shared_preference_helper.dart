import 'dart:convert';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/model/subject.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  SharedPreferenceHelper._internal();
  static final SharedPreferenceHelper instance =
      SharedPreferenceHelper._internal();

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences once to improve performance.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> setAccessToken(String value) async {
    return _prefs!.setString(UserPreferenceKey.AccessToken.toString(), value);
  }

  Future<String?> getAccessToken() async {
    return _prefs!.getString(UserPreferenceKey.AccessToken.toString());
  }

  // Add static method to get token for easier access in chat pages
  static Future<String?> getToken() async {
    return _prefs!.getString(UserPreferenceKey.AccessToken.toString());
  }

  // Add method to get user ID from the stored profile
  static Future<String?> getUserId() async {
    final jsonString = _prefs!.getString(
      UserPreferenceKey.UserProfile.toString(),
    );
    if (jsonString == null) return null;
    final userProfile = ActorModel.fromJson(json.decode(jsonString));
    return userProfile.id;
  }

  Future<bool> setUserName(String value) async {
    return _prefs!.setString(UserPreferenceKey.UserName.toString(), value);
  }

  Future<String?> getUserName() async {
    return _prefs!.getString(UserPreferenceKey.UserName.toString());
  }

  Future<void> clearPreferenceValues() async {
    await _prefs!.clear();
  }

  Future<void> saveUserProfile(ActorModel user) async {
    await _prefs!.setString(
      UserPreferenceKey.UserProfile.toString(),
      json.encode(user.toJson()),
    );
  }

  Future<ActorModel?> getUserProfile() async {
    final jsonString = _prefs!.getString(
      UserPreferenceKey.UserProfile.toString(),
    );
    if (jsonString == null) return null;
    return ActorModel.fromJson(json.decode(jsonString));
  }

  Future<bool> isStudent() async {
    return (await getUserProfile())?.isStudent ?? false;
  }

  Future<void> saveSubjects(SubjectResponseModel model) async {
    await _prefs!.setString(
      UserPreferenceKey.Subjects.toString(),
      json.encode(model.toJson()),
    );
  }

  Future<SubjectResponseModel?> getSubjects() async {
    final jsonString = _prefs!.getString(UserPreferenceKey.Subjects.toString());
    if (jsonString == null) return null;
    return SubjectResponseModel.fromJson(json.decode(jsonString));
  }

  Future<void> saveStudent(StudentResponseModel model) async {
    await _prefs!.setString(
      UserPreferenceKey.Students.toString(),
      json.encode(model.toJson()),
    );
  }

  Future<StudentResponseModel?> getStudents() async {
    final jsonString = _prefs!.getString(UserPreferenceKey.Students.toString());
    if (jsonString == null) return null;
    return StudentResponseModel.fromJson(json.decode(jsonString));
  }
}

enum UserPreferenceKey {
  LanguageCode,
  CountryISOCode,
  AccessToken,
  UserProfile,
  UserName,
  Subjects,
  Students,
}
