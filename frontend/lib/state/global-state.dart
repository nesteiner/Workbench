import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/api/clipboard-api.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/api/user-api.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/api/todolist-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/file-manager-controller.dart';
import 'package:frontend/model/websocket.dart';
import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:web_socket_channel/io.dart';
import 'package:frontend/model/websocket.dart' as ws;

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

  static Future<GlobalState> loadGlobalState(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // STUB
    // await prefs.clear();
    await plugin.initialize(InitializationSettings(linux: linuxSettings, android: androidSettings));
    tz.initializeTimeZones();
    final state = GlobalState(preferences: prefs, context: context);

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

    final loginApi = UserApi(loginUrl: state.loginUrl, userUrl: state.userUrl, defaultRoleUrl: state.defaultRoleUrl, errorHandler: errorHandler);
    final loginState = UserState(api: loginApi);
    state.userState = loginState;

    if (state.jwttoken == null) {
      return state;
    }


    final jwttoken = state.jwttoken!;
    await loginApi.setToken(jwttoken);

    final todoListApi = TodoListApi(todolistUrl: state.todolistUrl, errorHandler: errorHandler);
    final todolistState = TodoListState(api: todoListApi);
    state.todolistState = todolistState;

    final dailyAttendanceApi = DailyAttendanceApi(dailyAttendanceUrl: state.dailyAttendanceUrl, errorHandler: errorHandler);
    final dailyAttendanceState = DailyAttendanceState(api: dailyAttendanceApi, plugin: GlobalState.plugin);
    state.dailyAttendanceState = dailyAttendanceState;

    final sambaApi = SambaApi(sambaUrl: state.sambaUrl, sambaHostUrl: state.sambaHostUrl!, errorHandler: errorHandler);
    final sambaController = FileManagerController();
    final sambaState = SambaState(api: sambaApi, controller: sambaController);
    state.sambaState = sambaState;

    final clipboardApi = ClipboardApi(clipboardUrl: state.clipboardUrl, errorHandler: errorHandler);
    final clipboardState = ClipboardState(api: clipboardApi, size: 10);
    state.clipboardState = clipboardState;

    return state;
  }


  late SharedPreferences preferences;
  late bool isDesktop;
  UserState? _userState;
  TodoListState? _todolistState;
  DailyAttendanceState? _dailyAttendanceState;
  SambaState? _sambaState;
  ClipboardState? _clipboardState;
  BuildContext context;

  GlobalState({required this.preferences, required this.context}) {
    isDesktop = Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  UserState? get userState => _userState;
  TodoListState? get todolistState => _todolistState;
  DailyAttendanceState? get dailyAttendanceState => _dailyAttendanceState;
  SambaState? get sambaState => _sambaState;
  ClipboardState? get clipboardState => _clipboardState;


  set userState(UserState? value) {
    _userState = value;
  }

  set todolistState(TodoListState? value) {
    _todolistState = value;
    if (value != null) {
      userState?.passToken(value);
    }
  }

  set dailyAttendanceState(DailyAttendanceState? value) {
    _dailyAttendanceState = value;
    if (value != null) {
      userState?.passToken(value);
    }
  }

  set sambaState(SambaState? value) {
    _sambaState = value;

    if (value != null) {
      userState?.passToken(value);
    }
  }

  set clipboardState(ClipboardState? value) {
    _clipboardState = value;

    if (value != null) {
      userState?.passToken(value);
    }
  }

  Future<void> clear() async {
    await preferences.clear();
    userState = null;
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

  void bindWebsocket(IOWebSocketChannel websocket) {
    websocket.stream.listen((event) => listen(event),
        onError: (error) {
          final snackbar = SnackBar(content: Text("error occur: $error"));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }

    );
  }

  bool? get isconfigured => preferences.getBool(keyOfConfigured);
  String? get jwttoken => preferences.getString(keyOfJwtToken);
  String? get backendUrl => preferences.getString(keyOfBackendUrl);
  String? get sambaHostUrl => preferences.getString(keyOfSambaHostUrl);
  String? get sambaUser => preferences.getString(keyOfSambaUser);
  String? get sambaPassword => preferences.getString(keyOfSambaPassword);
  String? get nickname => preferences.getString(keyOfNickname);

  String get loginUrl => join(backendUrl!, "authenticate");
  String get userUrl => join(backendUrl!, "user");
  String get defaultRoleUrl => join(backendUrl!, "role/default");
  String get todolistUrl => join(backendUrl!, nickname!, "todolist");
  String get dailyAttendanceUrl => join(backendUrl!, nickname!, "daily-attendance");
  String get sambaUrl => join(backendUrl!, nickname!, "samba");
  String get clipboardUrl => join(backendUrl!, nickname!, "clipboard");
  String get websocketUrl => join(backendUrl!.replaceAll("http", "ws"), "websocket", nickname!);

  Future<void> listen(dynamic event) async {
    final data = TransferData.fromJson(json.decode(event));
    final message = data.message;

    if (message is ws.Error) {
      listenError(message.message);
      return;
    }

    final operation = (message as ws.Notification).operation;

    switch (operation) {
      case TaskProjectPost _:
        await todolistState?.loadTaskProjects();
        break;

      case TaskProjectDelete operation1:
        todolistState?.taskprojects.removeWhere((element) => element.id == operation1.id);
        todolistState?.update();
        break;

      case TaskProjectUpdate _:
        await todolistState?.loadTaskProjects();
        break;

      case TaskGroupPost operation1:
        await todolistState?.loadTaskGroups(operation1.taskprojectId);
        break;

      case TaskGroupDelete operation1:
        todolistState?.taskgroups.removeWhere((element) => element.id == operation1.id);
        todolistState?.update();

        break;

      case TaskGroupUpdate operation1:
        if (todolistState?.currentProject?.id == operation1.taskprojectId) {
          await todolistState?.loadTaskGroups(operation1.taskprojectId);
        }

        break;

      case TaskPost operation1:
        await todolistState?.loadTaskGroup(operation1.taskgroupId);

        break;
        
      case TaskDelete operation1:
        final index = todolistState?.taskgroups.indexWhere((element) => element.id == operation1.taskgroupId) ?? -1;
        if (index != -1) {
          todolistState?.taskgroups[index].tasks.removeWhere((element) => element.id == operation1.id);
          todolistState?.update();
        }
        break;
        
      case TaskUpdate operation1:
        final index = todolistState?.taskgroups.indexWhere((element) => element.id == operation1.taskgroupId) ?? -1;
        if (index != -1) {
          final tasks = todolistState?.taskgroups[index].tasks ?? [];
          final index1 = tasks.indexWhere((element) => element.id == operation1.id) ?? -1;
          
          if (index1 != -1) {
            tasks[index1] = await todolistState!.loadTask(operation1.id);
          }
          
        }
        
        break;

      case DailyAttendancePost _:
        await dailyAttendanceState?.findAllOfLatest7Days();
        break;
      case DailyAttendanceDelete operation1:
        for (final entry in dailyAttendanceState!.tasksOf7Days.entries){
          final tasks = entry.value;
          final index = tasks.indexWhere((element) => element.id == operation1.id);
          if (index != -1) {
            tasks.removeAt(index);
            if (dailyAttendanceState?.currentDay != null) {
              dailyAttendanceState?.setCurrentDay(dailyAttendanceState!.currentDay!);
            }

            dailyAttendanceState?.update();
            break;
          }
        }

        break;

      case DailyAttendanceUpdate operation1:
        for (final entry in dailyAttendanceState!.tasksOf7Days.entries) {
          final tasks = entry.value;
          final index = tasks.indexWhere((element) => element.id == operation1.id);
          if (index != -1) {
            tasks[index] = await dailyAttendanceState!.findOne(operation1.id);

            if (dailyAttendanceState?.currentDay != null) {
              dailyAttendanceState?.setCurrentDay(dailyAttendanceState!.currentDay!);
            }

            dailyAttendanceState?.update();
            break;
          }
        }

        break;

      case ClipboardPost _:
        await clipboardState?.findAll();
        break;

      case ClipboardDelete operation1:
        clipboardState?.data.removeWhere((element) => element.id == operation1.id);
        final data = clipboardState!.data;
        final size = clipboardState!.size;
        final mod = data.length % size;
        if (mod == 0) {
          clipboardState!.page = (data.length / size).floor();
        } else {
          clipboardState!.page = (data.length / size).floor() + 1;
        }

        clipboardState?.update();

        break;

      case SambaUpdate operation1:
        if (sambaState?.controller.path == operation1.parentPath) {
          sambaState?.controller.update();
        }

        break;

      default:
        throw Exception("no such Operation type: $operation");
    }
  }

  Future<void> listenError(String message) async {

  }
}