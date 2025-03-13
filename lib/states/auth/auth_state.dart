import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gyansagar_frontend/resources/exceptions/exceptions.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';
import 'package:gyansagar_frontend/states/base_state.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthState extends BaseState {
  String? email;
  String? password;
  String? mobile;
  String? name;
  String? otp;

  bool isSignInWithGoogle = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  set setEmail(String value) => email = value;
  set setMobile(String value) => mobile = value;
  set setName(String value) => name = value;
  set setPassword(String value) => password = value;

  void saveOTP(String otp) {
    this.otp = otp;
    notifyListeners();
  }

  Future<bool> login() async {
    try {
      var model = ActorModel(
        name: name ?? "Unknown",
        email: email ?? "",
        password: password ?? "",
        mobile: mobile ?? "",
        role: "user",
        id: "",
        token: "",
        isVerified: false,
        lastLoginDate: DateTime.now(),
      );
      final repo = GetIt.instance.get<BatchRepository>();
      return await repo.login(model);
    } on ApiException catch (error) {
      final map = json.decode(error.message) as Map<String, dynamic>;
      ActorModel model = ActorModel.fromError(map);
      log("Login", error: error.message);
      throw Exception(model.email ?? model.password ?? model.mobile ?? "Unknown error");
    } on UnauthorisedException catch (error) {
      log("Login", error: error.message);
      throw Exception(error.message);
    } on UnprocessableException catch (error) {
      final map = json.decode(error.message) as Map<String, dynamic>;
      ActorModel model = ActorModel.fromError(map);
      log("Login", error: error.message, name: "UnprocessableException");
      throw Exception(model.email ?? model.password ?? model.mobile ?? model.name ?? "Unknown error");
    } catch (error, stackTrace) {
      log("Error", error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> register() async {
    try {
      var model = ActorModel(
        name: name ?? "Unknown",
        email: email ?? "",
        password: password ?? "",
        mobile: mobile ?? "",
        role: "user",
        id: "",
        token: "",
        isVerified: false,
        lastLoginDate: DateTime.now(),
      );
      final repo = GetIt.instance.get<BatchRepository>();
      return await repo.register(model);
    } on ApiException catch (error, stackTrace) {
      final map = json.decode(error.message) as Map<String, dynamic>;
      ActorModel model = ActorModel.fromError(map);
      log("Register", error: error.message, stackTrace: stackTrace, name: "ApiException");
      throw Exception(model.email ?? model.password ?? model.mobile ?? "Unknown error");
    } catch (error, stackTrace) {
      log("Error", error: error, stackTrace: stackTrace, name: "Register");
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    try {
      var otpInt = int.tryParse(otp ?? '');
      if (otpInt == null) throw Exception("Invalid OTP");

      var model = ActorModel(
        name: name ?? "Unknown",
        email: email ?? "",
        password: "",
        otp: otpInt,
        mobile: mobile ?? "",
        role: "user",
        id: "",
        token: "",
        isVerified: false,
        lastLoginDate: DateTime.now(),
      );
      final repo = GetIt.instance.get<BatchRepository>();
      return await repo.verifyOtp(model);
    } on ApiException catch (error, stackTrace) {
      final map = json.decode(error.message) as Map<String, dynamic>;
      ActorModel model = ActorModel.fromError(map);
      log("verifyOtp", error: error.message, stackTrace: stackTrace, name: "ApiException");
      throw Exception(model.email ?? model.password ?? model.mobile ?? "Unknown error");
    } catch (error, stackTrace) {
      log("Error", error: error, stackTrace: stackTrace, name: "verifyOtp");
      return false;
    }
  }

  Future<bool> forgetPassword() async {
    try {
      var model = ActorModel(
        name: name ?? "Unknown",
        email: email ?? "",
        password: "",
        mobile: mobile ?? "",
        role: "user",
        id: "",
        token: "",
        isVerified: false,
        lastLoginDate: DateTime.now(),
      );
      final repo = GetIt.instance.get<BatchRepository>();
      return await repo.forgotPassword(model);
    } catch (error, stackTrace) {
      log("Error", error: error, stackTrace: stackTrace, name: "forgetPassword");
      return false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    clearData();
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false; // the user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // TODO: Handle signed-in user
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log("signInWithGoogle error", error: error);
      return false;
    }
  }

  Future<bool> updateUser() async {
    try {
      // Implement your logic to update user password here
      return true;
    } catch (error) {
      log("updateUser error", error: error);
      return false;
    }
  }

  void clearData() {
    email = null;
    password = null;
    mobile = null;
    name = null;
    otp = null;
  }
}