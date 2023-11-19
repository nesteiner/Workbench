import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/page/daily_attendance/taskrecording.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:provider/provider.dart';

class TaskWidget extends StatelessWidget {
  final da.DailyAttendanceTask task;
  late final DailyAttendanceState state;

  TaskWidget({required this.task});

  @override
  Widget build(BuildContext context) {
    state = context.read<DailyAttendanceState>();

    final icon = Selector<DailyAttendanceState, da.Icon>(
      selector: (_, state) => task.icon,
      builder: (_, value, child) {
        if (value is da.IconWord) {
          return Container(
            width: settings["widget.daily-attendance.task.icon.size"],
            height: settings["widget.daily-attendance.task.icon.size"],
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value.color
            ),
            child: Center(child: Text(value.word, style: const TextStyle(color: Colors.white),)),
          );
        } else {
          final value1 = value as da.IconImage;
          return Container(
            width: settings["widget.daily-attendance.task.icon.size"],
            height: settings["widget.daily-attendance.task.icon.size"],
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),

            child: Center(child: Image.network(state.iconUrl(value1.entryId))),
          );
        }
      },
    );

    final text = Selector<DailyAttendanceState, ShowMode>(
      selector: (context, state) => state.mode,
      builder: (context, value, chld) {
        final style0 = settings["page.daily-attendance.taskrecording.font.days.style.0"];
        final style1 = settings["page.daily-attendance.taskrecording.font.days.style.1"];

        late Widget text0;
        late Widget days;

        if (value == ShowMode.persistence) {
          days = Text("${task.persistenceDays}天", style: style0,);
          text0 = Text("共坚持", style: style1,);
        } else {
          days = Text("${task.consecutiveDays}天", style: style0,);
          text0 = Text("连续坚持", style: style1,);
        }

        return Column(
          children: [
            days,
            text0
          ],
        );
      },
    );

    final container = Container(
      // height: settings["widget.daily-attendance.task.height"],
      padding: settings["widget.daily-attendance.task.padding"],
      width: double.infinity,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: settings["widget.daily-attendance.task.icon.margin"],),
              Text(task.name)
            ],
          ),

          GestureDetector(
            onTap: () {
              state.swithMode();
            },
            child: text,
          )
        ],
      ),
    );

    // 为了使整个组件都能被点击，使用 InkWell
    return InkWell(
      onTap: () {
        // navigator push TaskRecording
        state.setCurrentTask(task);
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskRecording()));
      },

      child: container,
    );
  }

}