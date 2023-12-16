import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/api/clipboard-api.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/api/login-api.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/api/todolist-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/file-manager-controller.dart';
import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/login-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class GlobalState extends ChangeNotifier {
  static final plugin = FlutterLocalNotificationsPlugin();
  static final linuxSettings = LinuxInitializationSettings(
      defaultActionName: "Open Notification",
      defaultIcon: AssetsLinuxIcon("assets/workbench.png"),
      defaultSound: AssetsLinuxSound("assets/notification.mp3")
  );

  static const androidSettings = AndroidInitializationSettings(
      "workbench"
  );

  static Future<GlobalState> loadGlobalState() async {
    final prefs = await SharedPreferences.getInstance();
    // STUB
    // await prefs.clear();
    await plugin.initialize(InitializationSettings(linux: linuxSettings, android: androidSettings));

    final state = GlobalState(preferences: prefs);

    Future<void> errorHandler(DioException exception) async {
      logger.e("error: ", error: exception.error);
      logger.e("error", stackTrace: exception.stackTrace);

      if (exception.response?.statusCode == 401) {
        await state.logout();
        logger.i("state logout");
        state.update();
      }
    }

    if (!(state.isconfigured ?? false)) {
      return state;
    }

    final loginApi = LoginApi(loginUrl: state.loginUrl!, userUrl: state.userUrl!, errorHandler: errorHandler);
    final loginState = LoginState(api: loginApi);
    state.loginState = loginState;

    if (state.jwttoken == null) {
      return state;
    }


    final jwttoken = state.jwttoken!;
    await loginApi.setToken(jwttoken);

    final todoListApi = TodoListApi(todolistUrl: state.todolistUrl!, errorHandler: errorHandler);
    final todolistState = TodoListState(api: todoListApi);
    state.todolistState = todolistState;

    final dailyAttendanceApi = DailyAttendanceApi(dailyAttendanceUrl: state.dailyAttendanceUrl!, errorHandler: errorHandler);
    final dailyAttendanceState = DailyAttendanceState(api: dailyAttendanceApi, plugin: GlobalState.plugin);
    state.dailyAttendanceState = dailyAttendanceState;

    final sambaApi = SambaApi(sambaUrl: state.sambaUrl!, sambaHostUrl: state.sambaHostUrl!, errorHandler: errorHandler);
    final sambaController = FileManagerController();
    final sambaState = SambaState(api: sambaApi, controller: sambaController);
    state.sambaState = sambaState;

    final clipboardApi = ClipboardApi(clipboardUrl: state.clipboardUrl!, errorHandler: errorHandler);
    final clipboardState = ClipboardState(api: clipboardApi, size: 10);
    state.clipboardState = clipboardState;

    return state;
  }


  late SharedPreferences preferences;
  late bool isDesktop;
  LoginState? _loginState;
  TodoListState? _todolistState;
  DailyAttendanceState? _dailyAttendanceState;
  SambaState? _sambaState;
  ClipboardState? _clipboardState;


  GlobalState({required this.preferences}) {
    isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  LoginState? get loginState => _loginState;
  TodoListState? get todolistState => _todolistState;
  DailyAttendanceState? get dailyAttendanceState => _dailyAttendanceState;
  SambaState? get sambaState => _sambaState;
  ClipboardState? get clipboardState => _clipboardState;


  set loginState(LoginState? value) {
    _loginState = value;
  }

  set todolistState(TodoListState? value) {
    _todolistState = value;
    if (value != null) {
      loginState?.passToken(value);
    }
  }

  set dailyAttendanceState(DailyAttendanceState? value) {
    _dailyAttendanceState = value;
    if (value != null) {
      loginState?.passToken(value);
    }
  }

  set sambaState(SambaState? value) {
    _sambaState = value;

    if (value != null) {
      loginState?.passToken(value);
    }
  }

  set clipboardState(ClipboardState? value) {
    _clipboardState = value;

    if (value != null) {
      loginState?.passToken(value);
    }
  }

  Future<void> clear() async {
    await preferences.clear();
    loginState = null;
    todolistState = null;
    dailyAttendanceState = null;
    sambaState = null;
    clipboardState = null;
  }

  Future<void> logout() async {
    await preferences.remove(keyOfJwtToken);

    todolistState = null;
    dailyAttendanceState = null;
    sambaState = null;
    clipboardState = null;
  }

  void update() {
    notifyListeners();
  }

  bool? get isconfigured => preferences.getBool(keyOfConfigured);
  String? get jwttoken => preferences.getString(keyOfJwtToken);
  String? get backendUrl => preferences.getString(keyOfBackendUrl);
  String? get sambaHostUrl => preferences.getString(keyOfSambaHostUrl);
  String? get sambaUser => preferences.getString(keyOfSambaUser);
  String? get sambaPassword => preferences.getString(keyOfSambaPassword);

  String? get loginUrl => join(backendUrl!, "authenticate");
  String? get userUrl => join(backendUrl!, "user");
  String? get todolistUrl => join(backendUrl!, "todolist");
  String? get dailyAttendanceUrl => join(backendUrl!, "daily-attendance");
  String? get sambaUrl => join(backendUrl!, "samba");
  String? get clipboardUrl => join(backendUrl!, "clipboard");

}