import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/page/login/loginpage.dart';
import 'package:frontend/page/todolist/taskproject.dart';
import 'package:frontend/state.dart';
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

    return ChangeNotifierProvider(
      create: (_) => GlobalState(
          api: Api(
              loginUrl: "http://localhost:8082/api/authenticate",
              userUrl: "http://localhost:8082/api/user",
              todolistUrl: "http://localhost:8082/api/todolist"
          )
      ),
      child: MaterialApp(
        title: "Test Page",
        home: LoginPage(),
        navigatorKey: navigatorKey,
        routes: {
          "/login": (_) => LoginPage(),
          "/taskproject": (_) => TaskProjectPage()
        },
      )
    );
  }
}