import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/clipboard-api.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/controller/file-manager-controller.dart';
import 'package:frontend/page/register-page.dart';
import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/api/todolist-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';


/// this page need to be repalced with RootPage
class LoginPage extends StatelessWidget {
  UserState?  _state;
  UserState get state => _state!;
  set state(UserState value) => _state ??= value;

  GlobalState? _globalState;
  GlobalState get globalState => _globalState!;
  set globalState(GlobalState value) => _globalState ??= value;

  final usernameController = TextEditingController(text: "steiner");
  final passwordController = TextEditingController(text: "password");

  bool get disabled => usernameController.text.isEmpty || passwordController.text.isEmpty;
  late ValueNotifier<bool> disabledNotifier;

  LoginPage() {
    disabledNotifier = ValueNotifier(disabled);
  }

  @override
  Widget build(BuildContext context) {
    state = context.read<UserState>();
    globalState = context.read<GlobalState>();
    return Scaffold(
      appBar: AppBar(title: const Text("登录"),),
      body: buildBody(context),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget buildBody(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: settings["page.login.body.margin-top"],),
        const Icon(Icons.login, size: 200,),
        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "用户名",
              hintText: "输入用户名"
            ),

            onChanged: (value) {
              disabledNotifier.value = disabled;
            },
          ),
        ),

        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "密码",
              hintText: "输入密码",
            ),

            onChanged: (value) {
              disabledNotifier.value = disabled;
            },
          ),
        ),

        ValueListenableBuilder(
          valueListenable: disabledNotifier,
          builder: (context, value, child) => ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(settings["page.login.button.height"])
            ),

            onPressed: value ? null : () async {
                try {
                  await state.login(usernameController.text, passwordController.text);
                  await globalState.preferences.setString(keyOfJwtToken, "Bearer ${state.api.jwttoken}");

                  socket = IOWebSocketChannel.connect(globalState.websocketUrl);
                  globalState.bindWebsocket(socket!);

                  final todoListApi = TodoListApi(todolistUrl: globalState.todolistUrl, errorHandler: onError);
                  final todolistState = TodoListState(api: todoListApi);
                  globalState.todolistState = todolistState;

                  final dailyAttendanceApi = DailyAttendanceApi(dailyAttendanceUrl: globalState.dailyAttendanceUrl, errorHandler: onError);
                  final dailyAttendanceState = DailyAttendanceState(api: dailyAttendanceApi, plugin: GlobalState.plugin);
                  globalState.dailyAttendanceState = dailyAttendanceState;

                  final sambaApi = SambaApi(sambaUrl: globalState.sambaUrl, sambaHostUrl: globalState.sambaHostUrl!, errorHandler: onError);
                  final sambaController = FileManagerController();
                  final sambaState = SambaState(api: sambaApi, controller: sambaController);
                  globalState.sambaState = sambaState;

                  final clipboardApi = ClipboardApi(clipboardUrl: globalState.clipboardUrl, errorHandler: onError);
                  final clipboardState = ClipboardState(api: clipboardApi, size: 10);
                  globalState.clipboardState = clipboardState;

                  globalState.update();
                } on DioException catch (exception) {
                  if (!context.mounted) {
                    return;
                  }

                  logger.e("login page", stackTrace: exception.stackTrace);
                  await showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => AlertDialog(
                      content: Text(exception.message ?? "fuck"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            navigatorKey.currentState?.pop();
                            // Navigator.pop(context);
                          },

                          child: const Text("确定"),
                        )
                      ],
                    )
                  );

                }
              },

            child: const Text("Login", style: TextStyle(color: Colors.white),),
          ),
        ),
        
        const Expanded(child: Align(
          alignment: Alignment.bottomCenter,
          child: Icon(Icons.arrow_upward, color: Color.fromRGBO(0, 0, 0, 0.3), size: 30,),
        ))
      ],
    );

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: column,
      ),
    );
  }

  Future<void> onError(DioException exception) async {
    if (exception.response?.statusCode == 401) {
      await globalState.logout();
      globalState.update();
    }
  }
}