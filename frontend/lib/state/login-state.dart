import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/login-api.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/todolist-state.dart';

class LoginState extends ChangeNotifier {
  final LoginApi api;
  final TodoListState todoListState;
  final DailyAttendanceState dailyAttendanceState;

  LoginState({required this.api, required this.todoListState, required this.dailyAttendanceState});

  Future<bool> login(String username, String password) async {
    try {
      await api.login(username, password);
      api.passToken(todoListState);
      api.passToken(dailyAttendanceState);

      return true;
    } on DioException catch (exception, stacktrace) {
      print(exception);
      print(stacktrace);
      return false;
    }
  }
}