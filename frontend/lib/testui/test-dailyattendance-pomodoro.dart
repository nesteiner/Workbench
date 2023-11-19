import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/api/login-api.dart';
import 'package:frontend/api/todolist-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/page/login/loginpage.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/login-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/widget/daily_attendance/task.dart';
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
        debugShowCheckedModeBanner: false,
        title: "Test Page",
        routes: {
          "/": (_) => HomePage(),
        },
        navigatorKey: navigatorKey,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  late final LoginState loginState;
  late final DailyAttendanceState dailyAttendanceState;

  @override
  Widget build(BuildContext context) {
    loginState = context.read<LoginState>();
    dailyAttendanceState = context.read<DailyAttendanceState>();

    return Scaffold(
      appBar: AppBar(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return FutureBuilder(
        future: loginState.login("steiner", "password"),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("error in login: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }


          return Center(
            child: FutureBuilder(
              future: dailyAttendanceState.findAllOfCurrentDay(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.stackTrace);
                  return Text("error in find current day: ${snapshot.error}");
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }


                return Selector<DailyAttendanceState, String>(
                  selector: (_, state) {
                    return dailyAttendanceState.tasks.entries
                        .map((entry) => "${entry.value.toString()}-${entry.value.map((e) => e.toString()).join(",")}")
                        .join(",");
                  },

                  builder: (_, value, child) {
                    return ListView.builder(
                      itemCount: dailyAttendanceState.tasks.length,
                      itemBuilder: (context, index) {
                        final key = dailyAttendanceState.tasks.keys.elementAt(index);
                        final values = dailyAttendanceState.tasks[key]!;
                        List<Widget> children = [];

                        return StatefulBuilder(builder: (context, setState) => ExpansionTile(
                          key: PageStorageKey(key),
                          onExpansionChanged: (value) {
                            if (value) {
                              setState(() {
                                children = values.map((e) => TaskWidget(task: e)).toList();
                              });
                            } else {
                              setState(() {
                                children = [];
                              });
                            }
                          },

                          title: Text(key.stringValue2(), style: const TextStyle(color: Colors.grey),),
                          children: children
                        ));
                      },
                    );
                  },
                );
              },
            ),
          );
        }
    );
  }
}