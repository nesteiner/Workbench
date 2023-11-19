import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/api/login-api.dart';
import 'package:frontend/api/todolist-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/page/login/loginpage.dart';
import 'package:frontend/page/todolist/taskproject.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/login-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      setWindowMinSize(const Size(800, 600));
    }

    final todoListState = TodoListState(api: TodoListApi(
      todolistUrl: "http://localhost:8082/api/todolist",
    ));
    
    final dailyAttendanceState = DailyAttendanceState(api: DailyAttendanceApi(
      dailyAttendanceUrl: "http://localhost:8082/api/daily-attendance"
    ));
    
    final loginApi = LoginApi(loginUrl: "http://localhost:8082/api/authenticate", userUrl: "http://localhost:8082/api/user");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginState(api: loginApi, todoListState: todoListState, dailyAttendanceState: dailyAttendanceState)),
        ChangeNotifierProvider(create: (_) => todoListState),
        ChangeNotifierProvider(create: (_) => dailyAttendanceState)
      ],
      
      child: MaterialApp(
        title: "Test Page",
        home: LoginPage(),
        navigatorKey: navigatorKey,
        routes: {
          "/login": (_) => LoginPage(),
          "/taskproject": (_) => TaskProjectPage()
        },
      ),
    );
  }
}