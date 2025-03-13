import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/resources/repository/batch_repository.dart';
import 'package:get_it/get_it.dart';

class BaseState extends ChangeNotifier {
  bool _isBusy = false;
  final getit = GetIt.instance;
  bool get isBusy => _isBusy;

  set isBusy(bool val) {
    _isBusy = val;
    notifyListeners();
  }

  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void log(String message, {dynamic error, StackTrace? stackTrace}) {
    developer.log(message, error: error, stackTrace: stackTrace);
  }

  Future<T?> execute<T>(Future<T> Function() handler,
      {String label = "Error"}) async {
    try {
      return await handler();
    } catch (error, stackTrace) {
      log(label, error: error, stackTrace: stackTrace);
      return null; // Now allowed since return type is Future<T?>
    }
  }

  /// in `idAndType` param pass resource id and its type
  ///
  /// For example to delete a video pass `video/sdfsdf9878sd7f87sd7f89dfsd` as parameter.
  Future<bool> deleteById(String idAndType, {String label = "Delete"}) async {
    try {
      final repo = getit.get<BatchRepository>();
      return await repo.deleteById(idAndType);
    } catch (error) {
      developer.log(label, error: error, name: runtimeType.toString());
      return false;
    }
  }
}