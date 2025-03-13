import 'package:gyansagar_frontend/helper/shared_preference_helper.dart';
import 'package:gyansagar_frontend/resources/exceptions/exceptions.dart';
import 'package:gyansagar_frontend/resources/service/api_gateway.dart';
import 'package:gyansagar_frontend/resources/service/session/session.dart';
import 'package:gyansagar_frontend/model/actor_model.dart';

class SessionServiceImpl implements SessionService {
  final ApiGateway _apiGateway;
  final SharedPreferenceHelper pref;
  SessionServiceImpl(
      this._apiGateway,
      this.pref,
      );

  Future<void> saveSession(ActorModel session) async {
    await pref.saveUserProfile(session);
    await pref.setAccessToken(session.token);
    print("Session Save in local!!");
  }

  Future<ActorModel?> loadSession() async {
    try {
      var session = await pref.getUserProfile();
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await pref.clearPreferenceValues();
    print("Session clear");
  }

  @override
  Future<T> refreshSessionOnUnauthorized<T>(
      Future<T> Function() handler) async {
    try {
      return await handler();
    } on ApiUnauthorizedException catch (_) {
      await refreshSession();
      return await handler();
    }
  }

  @override
  Future<void> refreshSession() async {
    final session = await loadSession();
    // Implement the refresh session logic here
    // if (session != null) {
    //   final request = TokenRequest(
    //     clientId: _config.apiClientId,
    //     scope: 'write',
    //     secret: _config.apiSecretKey,
    //     username: session.email,
    //     password: session.password,
    //     grantType: 'password',
    //   );

    //   final token = await _apiGateway.token(request);
    //   final profile = await _profileGateway.getProfileByToken(token);
    //   final updatedSession = ActorModel(
    //     email: session.email,
    //     password: session.password,
    //     accessToken: token.access_token,
    //     refreshToken: token.refresh_token,
    //     tokenType: token.token_type,
    //     userId: profile.result.id,
    //     leClickUserId: getLeLickUserId(profile),
    //   );

    //   await saveSession(updatedSession);
    // } else {
    //   await clearSession();
    //   // throw InvalidSessionException();
    // }
  }
}