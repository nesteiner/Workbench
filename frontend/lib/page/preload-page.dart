import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/clipboard-api.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/api/user-api.dart';
import 'package:frontend/api/preload-api.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/api/todolist-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/file-manager-controller.dart';
import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class PreloadPage extends StatefulWidget {
  PreloadPageState createState() => PreloadPageState();
}

class PreloadPageState extends State<PreloadPage> {
  final loadingSnackbar = const SnackBar(content: Text("loading"),);
  final okSnackbar = const SnackBar(content: Text("ok"));

  final errSnackbar = const SnackBar(content: Text("error"));
  final emptySnackbar = const SnackBar(content: Text("text cannot be empty"));
  
  ScaffoldMessengerState? scaffoldMessenger;
  GlobalState? _state;
  GlobalState get state => _state!;
  set state(GlobalState value) => _state ??= value;

  final api = PreloadApi();
  // for modify
  int index = 0;

  // for get device info
  final deviceInfo = DeviceInfoPlugin();

  final Map<String, TextEditingController> controllers = {
    "backend-url": TextEditingController(text: "http://192.168.31.72:8082/api"),
    "samba-host-url": TextEditingController(text: "192.168.31.72"),
    "samba-user": TextEditingController(text: "steiner"),
    "samba-password": TextEditingController(text: "779151714"),
    "nickname": TextEditingController()
  };

  String get backendUrl => controllers["backend-url"]!.text;
  String get sambaHostUrl => controllers["samba-host-url"]!.text;
  String get sambaUser => controllers["samba-user"]!.text;
  String get sambaPassword => controllers["samba-password"]!.text;
  String get nickname => controllers["nickname"]!.text;
  
  @override
  Widget build(BuildContext context) {
    scaffoldMessenger ??= ScaffoldMessenger.of(context);
    state = context.read<GlobalState>();

    return Scaffold(
      appBar: AppBar(title: const Text("第一次加载"),),
      body: buildBody(context),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget buildBody(BuildContext context) {
    return Stepper(
      currentStep: index,
      onStepCancel: () {
        if (index > 0) {
          setState(() {
            index -= 1;
          });
        }
      },

      onStepContinue: () async {
        switch (index) {
          case 0:
            if (backendUrl.isEmpty) {
              scaffoldMessenger?.showSnackBar(emptySnackbar);
              break;
            }
            
            scaffoldMessenger?.clearSnackBars();
            scaffoldMessenger?.showSnackBar(loadingSnackbar);
            final result = await api.checkConnection(backendUrl);
            if (result) {
              scaffoldMessenger?.clearSnackBars();
              scaffoldMessenger?.showSnackBar(okSnackbar);
              setState(() {
                index += 1;
              });
            } else {
              scaffoldMessenger?.clearSnackBars();
              scaffoldMessenger?.showSnackBar(errSnackbar);
            }
            
            break;
            
          case 1:
            if (sambaHostUrl.isEmpty || sambaUser.isEmpty || sambaPassword.isEmpty) {
              scaffoldMessenger?.clearSnackBars();
              scaffoldMessenger?.showSnackBar(emptySnackbar);
              break;
            }
            
            scaffoldMessenger?.clearSnackBars();
            scaffoldMessenger?.showSnackBar(loadingSnackbar);
            
            final result = await api.checkLogin(backendUrl, sambaHostUrl, sambaUser, sambaPassword);
            if (!result) {
              scaffoldMessenger?.clearSnackBars();
              scaffoldMessenger?.showSnackBar(errSnackbar);
              break;
            }

            setState(() {
              index += 1;
            });
            scaffoldMessenger?.clearSnackBars();
            scaffoldMessenger?.showSnackBar(okSnackbar);

          case 2:
            await Future.wait([
              state.preferences.setString(keyOfNickname, nickname),
              state.preferences.setString(keyOfBackendUrl, backendUrl),
              state.preferences.setString(keyOfSambaHostUrl, sambaHostUrl),
              state.preferences.setString(keyOfSambaUser, sambaUser),
              state.preferences.setString(keyOfSambaPassword, sambaPassword)
            ]);

            state.preferences.setBool(keyOfConfigured, true);
            final loginApi = UserApi(loginUrl: state.loginUrl, userUrl: state.userUrl, defaultRoleUrl: state.defaultRoleUrl, errorHandler: errorHandler);
            final loginState = UserState(api: loginApi);
            state.userState = loginState;

            final todolistApi = TodoListApi(todolistUrl: state.todolistUrl, errorHandler: errorHandler);
            final todolistState = TodoListState(api: todolistApi);
            state.todolistState = todolistState;

            final dailyAttendanceApi = DailyAttendanceApi(dailyAttendanceUrl: state.dailyAttendanceUrl, errorHandler: errorHandler);
            final dailyAttendanceState = DailyAttendanceState(api: dailyAttendanceApi, plugin: GlobalState.plugin);
            state.dailyAttendanceState = dailyAttendanceState;

            final sambaApi = SambaApi(sambaUrl: state.sambaUrl, sambaHostUrl: sambaHostUrl, errorHandler: errorHandler);
            final sambaState = SambaState(api: sambaApi, controller: FileManagerController());
            state.sambaState = sambaState;

            final clipboardApi = ClipboardApi(clipboardUrl: state.clipboardUrl, errorHandler: errorHandler);
            final clipboardState = ClipboardState(api: clipboardApi, size: 10);
            state.clipboardState = clipboardState;

            state.update();
            break;
        }
      },

      onStepTapped: (index1) {
        setState(() {
          index = index1;
        });
      },

      steps: [
        Step(
          title: const Text("设置后端接口地址"),
          content: TextField(
            controller: controllers["backend-url"]!,
            decoration: const InputDecoration(
              hintText: "输入后端接口地址",
              labelText: "后端接口地址"
            ),
          )
        ),

        Step(
            title: const Text("设置 samba"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controllers["samba-host-url"]!,
                  decoration: const InputDecoration(
                    hintText: "输入 samba 主机地址",
                    labelText: "samba 主机地址"
                  ),
                ),

                TextField(
                  controller: controllers["samba-user"]!,
                  decoration: const InputDecoration(
                    hintText: "输入 samba 用户名",
                    labelText: "samba 用户名"
                  ),
                ),

                TextField(
                  controller: controllers["samba-password"]!,
                  decoration: const InputDecoration(
                    hintText: "输入 samba 密码",
                    labelText: "samba 密码"
                  ),
                )
              ],
            )
        ),

        Step(
          title: const Text("设置 昵称"),
          content: FutureBuilder(
            future: loadDeviceInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              controllers["nickname"]!.text = snapshot.requireData;
              return TextField(
                controller: controllers["nickname"],
                decoration: const InputDecoration(
                    hintText: "输入 昵称",
                    labelText: "昵称"
                ),
              );
            }
          )
        )
      ],
    );
  }

  Future<void> errorHandler(DioException exception) async {
    logger.e("error", error: exception.error, stackTrace: exception.stackTrace);

    if (exception.response?.statusCode == 401) {
      await state.logout();
      state.update();
    }
  }

  Future<String> loadDeviceInfo() async {
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.model;
    } else if (Platform.isLinux) {
      final linux = await deviceInfo.linuxInfo;
      return linux.name;
    } else if (Platform.isWindows) {
      final windows = await deviceInfo.windowsInfo;
      return windows.computerName;
    } else {
      throw Exception("this platform is not supported");
    }
  }
}