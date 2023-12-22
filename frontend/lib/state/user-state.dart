import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/user-api.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/request/login.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:web_socket_channel/io.dart';

class UserState extends ChangeNotifier {
  final UserApi api;

  UserState({
    required this.api,
  });

  Future<bool> login(String username, String password) async {
    try {
      await api.login(username, password);
      return true;
    } on DioException catch (exception, stacktrace) {
      logger.e("login error", error: exception.error, stackTrace: stacktrace);
      return false;
    }
  }

  int get userid => api.user!.id;

  void passToken(Api other) {
    api.passToken(other);
  }

  Future<void> register({required String username, required String password, required String email}) async {
    final role = await api.findDefaultRole();
    final request = PostUserRequest(name: username, roles: [role], email: email, password: password);
    await api.register(request);
  }
  
}