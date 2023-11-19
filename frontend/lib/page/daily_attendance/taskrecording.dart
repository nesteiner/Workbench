import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/daily-attendance.dart' as da show IconWord, IconImage, DailyAttendanceTask, Icon;
import 'package:frontend/page/daily_attendance/taskedit.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:provider/provider.dart';

/// ATTENTION
/// 这里不用一个 类变量 task 来代表 state.currentTask 的原因是，state.currentTask 要赋予新值，
/// 这个时候 task 无法随之更新
class TaskRecording extends StatelessWidget {
  late final DailyAttendanceState state;
  late final Widget backgroundImage;

  @override
  Widget build(BuildContext context) {
    state = context.read<DailyAttendanceState>();

    backgroundImage = Selector<DailyAttendanceState, int?>(
      selector: (_, state) {
        int? id;
        final task = state.currentTask!;
        if (task.icon is da.IconImage) {
          final icon = task.icon as da.IconImage;
          id = icon.backgroundId;
        }

        return id;
      },

      builder: (_, value, child) {
        if (value == null) {
          // backgroundColor = settings["page.daily-attendance.taskrecording.background.default-color"];

          return Image.asset(
            "assets/record.png",
            width: settings["page.daily-attendance.taskrecording.background.icon.size"],
            height: settings["page.daily-attendance.taskrecording.background.icon.size"],
          );
        } else {
          // backgroundColor = value.$2!;

          return Image.network(
            state.iconUrl(value),
            width: settings["page.daily-attendance.taskrecording.background.icon.size"],
            height: settings["page.daily-attendance.taskrecording.background.icon.size"],
          );
        }
      },
    );

    return Selector<DailyAttendanceState, Color?>(
      selector: (_, state) {
        Color? color;
        final task = state.currentTask!;
        if (task.icon is da.IconImage) {
          final icon = task.icon as da.IconImage;
          color = icon.backgroundColor;
        }

        return color;
      },

      builder: (_, value, child) {
        final color = value ?? settings["page.daily-attendance.taskrecording.background.default-color"];
        return Scaffold(
          appBar: buildAppBar(context, color),
          body: buildBody(context, color),
        );
      },
    );
  }

  AppBar buildAppBar(BuildContext context, Color backgroundColor) {
    return AppBar(
      backgroundColor: backgroundColor,

      actions: [
        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
                child: SizedBox(
                    width: settings["page.daily-attendance.taskrecoring.menu.width"],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit, color: Colors.black,),
                        SizedBox(width: settings["common.unit.size"],),
                        const Text("编辑")
                      ],
                    ),
                ),

              onTap: () {
                navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskEdit()));
              },
            ),

            PopupMenuItem(
                child: SizedBox(
                  width: settings["page.daily-attendance.taskrecoring.menu.width"],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.archive, color: Colors.black,),
                      SizedBox(width: settings["common.unit.size"]),
                      const Text("归档")
                    ],
                  ),
                )
            ),

            PopupMenuItem(
              child: SizedBox(
                width: settings["page.daily-attendance.taskrecoring.menu.width"],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_forever_outlined, color: Colors.black,),
                    SizedBox(width: settings["common.unit.size"],),
                    const Text("归档")
                  ],
                ),
              )
            )
          ],

          child: const Icon(Icons.more_vert),
        )
      ],
    );
  }

  Widget buildBody(BuildContext context, Color backgroundColor) {
    final task = state.currentTask!;
    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: BoxDecoration(
        color: backgroundColor
      ),


      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          backgroundImage,
          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.0"],),
          Text(task.name, style: TextStyle(color: settings["page.daily-attendance.taskrecording.font.color"], fontSize: settings["page.daily-attendance.taskrecording.font.title.size"]),),
          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.1"],),
          Text(task.encouragement, style: TextStyle(color: settings["page.daily-attendance.taskrecording.font.color"], fontSize: settings["page.daily-attendance.taskrecording.font.encouragement.size"]),),
          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.2"],),

          Text("Switch here")
        ],
      ),

    );
  }
}