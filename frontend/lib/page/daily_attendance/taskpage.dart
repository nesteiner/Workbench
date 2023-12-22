import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/page/daily_attendance/statistics.dart';
import 'package:frontend/page/daily_attendance/taskadd.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/widget/daily_attendance/date-select-panel.dart';
import 'package:frontend/widget/daily_attendance/task.dart';
import 'package:provider/provider.dart';

class TaskPage extends StatelessWidget {
  DailyAttendanceState? _state;
  DailyAttendanceState get state => _state!;
  set state(DailyAttendanceState value) => _state ??= value;

  @override
  Widget build(BuildContext context) {
    state = context.read<DailyAttendanceState>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("打卡", style: settings["page.daily-attendance.taskpage.appbar.text-style"],),
        actions: [
          InkWell(
            onTap: () {
              dailyAttendnaceNavigatorKey.currentState?.pushNamed(dailyAttendanceRoutes["task-manage"]!);
            },

            child: Image.asset("assets/tar.png"),
          ),

          InkWell(
            onTap: () {
              dailyAttendnaceNavigatorKey.currentState?.pushNamed(dailyAttendanceRoutes["statistics"]!);
            },

            child: Image.asset("assets/statistics.png"),
          )
        ],
      ),

      body: buildBody(context),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dailyAttendnaceNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskAdd()));
        },

        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return FutureBuilder(
        future: state.findAllOfLatest7Days(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e("task page buildbody", error: snapshot.error, stackTrace: snapshot.stackTrace);
            return Center(child: Text(snapshot.error.toString()),);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final restPart = Selector<DailyAttendanceState, String>(
            selector: (_, state) {
              final item1 = state.currentDay.toString();

              final item2 = state.tasks.entries
                  .map((entry) => "${entry.key}-${entry.value.map((e) => e.toString()).join(",")}")
                  .join(",");

              return "$item1-$item2";
            },

            builder: (_, value, child) {
              final sortedKeys = state.tasks.keys.toList()..sort();
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {

                  final key = sortedKeys[index];
                  final values = state.tasks[key]!;
                  List<Widget> children = values.where((element) => element.progress is! da.ProgressNotScheduled).map((e) => TaskWidget(task: e)).toList();

                  return StatefulBuilder(builder: (context, setState) => ExpansionPanel(
                    builder: (_) {
                      if (children.length == 0 && values.where((element) => element.progress is! da.ProgressNotScheduled).isEmpty) {
                        return null;
                      }

                      return ExpansionTile(
                          key: PageStorageKey("${state.currentDay}-$key"),
                          initiallyExpanded: true,
                          onExpansionChanged: (value) {
                            if (value) {
                              setState(() {
                                children = values.where((element) => element.progress is! da.ProgressNotScheduled).map((e) => TaskWidget(task: e)).toList();
                              });
                            } else {
                              setState(() {
                                children = [];
                              });
                            }
                          },

                          title: Text(key.stringValue2(), style: const TextStyle(color: Colors.grey),),
                          children: children
                      );

                    },
                  ));
                },
              );
            },
          );

          final headPart = DateSelectPanel();

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              headPart,
              Expanded(child: restPart)
            ],
          );
        }
    );
  }
}


class ExpansionPanel extends StatelessWidget {
  static ThemeData? theme;
  final Widget? Function(BuildContext) builder;
  ExpansionPanel({required this.builder});
  
  @override
  Widget build(BuildContext context) {
    theme ??= Theme.of(context).copyWith(dividerColor: Colors.transparent);
    final child = builder(context);

    if (child == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
          padding: settings["page.daily-attendance.task-page.expansion-panel.padding"],
          margin: settings["page.daily-attendance.task-page.expansion-panel.margin"],
          decoration: settings["page.daily-attendance.task-page.expansion-panel.decoration"],
          child: Theme(
            data: theme!,
            child: child,
          )
      );
    }
  }
}