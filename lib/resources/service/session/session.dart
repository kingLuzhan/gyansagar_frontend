import 'package:gyansagar_frontend/model/actor_model.dart';

abstract class SessionService {

  Future<void> saveSession(ActorModel register);

  Future<ActorModel> loadSession();

  Future<void> refreshSession();

  Future<void> clearSession();

  Future<T> refreshSessionOnUnauthorized<T>(Future<T> Function() handler);
}
