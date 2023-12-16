import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/login-api.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/todolist-state.dart';

class LoginState extends ChangeNotifier {
  final LoginApi api;

  LoginState({
    required this.api,
  });

  Future<bool> login(String username, String password) async {
    try {
      await api.login(username, password);
      return true;
    } on DioException catch (exception, stacktrace) {
      logger.e(exception.error);
      logger.e("login error", stackTrace: stacktrace);
      return false;
    }
  }

  int get userid => api.user!.id;

  void passToken(Api other) {
    api.passToken(other);
  }
}