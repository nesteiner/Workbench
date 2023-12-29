import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/page/daily_attendance/color-select.dart';
import 'package:frontend/page/daily_attendance/statistics.dart';
import 'package:frontend/page/daily_attendance/taskadd.dart';
import 'package:frontend/page/daily_attendance/taskedit.dart';
import 'package:frontend/page/daily_attendance/taskmanage.dart';
import 'package:frontend/page/daily_attendance/taskpage.dart';
import 'package:frontend/page/daily_attendance/taskrecording.dart';
import 'package:frontend/page/home-page.dart';
import 'package:frontend/page/samba/samba-page.dart';
import 'package:frontend/page/todolist/taskdetail.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/page/todolist/taskproject.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widget/keepalive.dart';
import 'package:frontend/widget/pomodoro/pomodoro-board.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class RootPage extends StatefulWidget {
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with SingleTickerProviderStateMixin {
  final controller = SidebarXController(selectedIndex: 0);
  late final TabController tabController;

  GlobalState? _state;

  GlobalState get state => _state!;

  set state(GlobalState value) => _state ??= value;

  Map<String, Widget>? _pageRecord;

  Map<String, Widget> get pageRecord => _pageRecord!;

  set pageRecord(Map<String, Widget> value) => _pageRecord ??= value;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    state = context.read<GlobalState>();
    pageRecord = {
      "home": HomePage(),
      "todolist": Navigator(
        key: todolistNavigatorKey,
        initialRoute: routes["todolist"]!,
        onGenerateRoute: (settings1) {
          late Widget pageChild;
          if (settings1.name == routes["home"]! || settings1.name == todolistRoutes["taskproject"]!) {
            pageChild = TaskProjectPage();
          } else if (settings1.name!.endsWith(todolistRoutes["taskgroup-board"]!)) {
            pageChild = TaskGroupBoard(taskproject: state.todolistState!.currentProject!);
          } else if (settings1.name!.endsWith(todolistRoutes["taskdetail"]!)) {
            pageChild = TaskDetail(task: state.todolistState!.currentTask!);
          } else if (settings1.name!.endsWith(todolistRoutes["pomodoro"]!)) {
            pageChild = PomodoroBoard();
          } else {
            throw Exception("todolist page: no route define for ${settings1.name}");
          }

          return MaterialPageRoute(builder: (_) => pageChild, settings: settings1);
        },
      ),

      "daily-attendance": Navigator(
        key: dailyAttendnaceNavigatorKey,
        initialRoute: routes["daily-attendance"]!,
        onGenerateRoute: (settings1) {
          late Widget pageChild;

          if (settings1.name == routes["home"]! || settings1.name == dailyAttendanceRoutes["taskpage"]!) {
            pageChild = TaskPage();
          } else if (settings1.name!.endsWith(dailyAttendanceRoutes["taskadd"]!)) {
            pageChild = TaskAdd();
          } else if (settings1.name!.endsWith(dailyAttendanceRoutes["taskedit"]!)) {
            pageChild = TaskEdit();
          } else if (settings1.name!.endsWith(dailyAttendanceRoutes["task-recording"]!)) {
            pageChild = TaskRecording();
          } else if (settings1.name!.endsWith(dailyAttendanceRoutes["statistics"]!)) {
            pageChild = StatisticsPage();
          } else if (settings1.name!.endsWith(dailyAttendanceRoutes["color-select"]!)) {
            pageChild = ColorSelect();
          } else if (settings1.name!.endsWith(dailyAttendanceRoutes["task-manage"]!)) {
            pageChild = TaskManage();
          } else {
            throw Exception("daily attendance page: no route define for ${settings1.name}");
          }

          return MaterialPageRoute(builder: (_) => pageChild, settings: settings1);
        },
      ),

      "samba": Navigator(
        key: sambaNavigatorKey,
        initialRoute: routes["samba"]!,
        onGenerateRoute: (settings1) {
          return MaterialPageRoute(builder: (_) => SambaPage(), settings: settings1);
        },
      ),

    };


    if (isDesktop) {
      return buildDesktop(context);
    } else {
      return buildMobile(context);
    }
  }

  Widget buildDesktop(BuildContext context) {
    return Scaffold(
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SidebarX(
              controller: controller,
              items: [
                SidebarXItem(icon: Icons.home, label: "home", onTap: () => tabController.index = 0),
                SidebarXItem(icon: Icons.list, label: "todolist", onTap: () => tabController.index = 1),
                SidebarXItem(icon: Icons.calendar_month, label: "daily attendance", onTap: () => tabController.index = 2),
                SidebarXItem(icon: Icons.file_open_outlined, label: "samba", onTap: () => tabController.index = 3),
                SidebarXItem(icon: Icons.logout, label: "logout", onTap: () async {
                  await state.logout();
                  state.update();
                }),
                SidebarXItem(icon: Icons.clear, label: "clear", onTap: () async {
                  await state.clear();
                  state.update();
                })
              ],
            ),

            Expanded(child: TabBarView(
              controller: tabController,
              children: [
                KeepAliveWrapper(child: pageRecord["home"]!),
                KeepAliveWrapper(child: pageRecord["todolist"]!),
                KeepAliveWrapper(child: pageRecord["daily-attendance"]!),
                KeepAliveWrapper(child: pageRecord["samba"]!),
              ],
            ))
          ],
        )
    );
  }

  Widget buildMobile(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TabBar(
        controller: tabController,
        tabs: const [
          Tab(icon: Icon(Icons.home),),
          Tab(icon: Icon(Icons.list)),
          Tab(icon: Icon(Icons.calendar_month),),
          Tab(icon: Icon(Icons.file_open_outlined),)
        ],),


      body: TabBarView(
        controller: tabController,
        children: [
          KeepAliveWrapper(child: pageRecord["home"]!),
          KeepAliveWrapper(child: pageRecord["todolist"]!),
          KeepAliveWrapper(child: pageRecord["daily-attendance"]!),
          KeepAliveWrapper(child: pageRecord["samba"]!)
        ],
      ),
    );
  }
}