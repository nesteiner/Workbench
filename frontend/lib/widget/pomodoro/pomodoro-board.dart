import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/pomodoro.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/state.dart';
import 'package:frontend/widget/pomodoro/counter.dart';
import 'package:frontend/widget/pomodoro/taskcard.dart';
import 'package:provider/provider.dart';

class PomodoroBoard extends StatelessWidget {
  late GlobalState state;

  @override
  Widget build(BuildContext context) {
    state = context.read<GlobalState>();
    // TODO: implement build
    final counter = CounterWidget();
    return Selector<GlobalState, (Task?, List<Task>, FocusState)>(
      selector: (_, state) => (state.currentTask, state.currentTaskGroup!.tasks, state.counter.focusState),
      builder: (_, value, child) {
        final currentTask = value.$1;
        final tasks = value.$2;
        final focusState = value.$3;

        final taskcards = tasks.map<Widget>((e) => TaskCard(task: e, isselected: currentTask?.id == e.id, taskgroupIndex: state.currentTaskGroup!.index)).toList();

        final column = Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            counter,
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [buildSelect(context),],),

            ...taskcards
          ],
        );

        return Container(
            decoration: BoxDecoration(color: getcolor(focusState)),
            child: SingleChildScrollView(
              child: column,
            )
        );
      },
    );

  }

  Widget buildSelect(BuildContext context) {
    final taskgroups = state.taskgroups;
    final popupbutton = PopupMenuButton(
      itemBuilder: (context) => taskgroups
          .map<PopupMenuItem>(
              (e) => PopupMenuItem(
                child: buildTaskGroup(context, e),
                onTap: () {
                  state.setCounterTaskGroup(e);
                },
              )).toList(),
      child: buildTaskGroup(context, state.currentTaskGroup!),
    );

    return Container(
      margin: settings["widget.pomodoro.taskcard.select.margin"],
      color: Colors.white,
      child: popupbutton,
    );
  }

  Widget buildTaskGroup(BuildContext context, TaskGroup taskgroup) {
    return SizedBox(
      width: settings["widget.pomodoro.pomodoro-board.taskgroup-menu.width.desktop"],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(taskgroup.name)
        ],
      ),
    );
  }

  Color getcolor(FocusState state) {
    if (state == FocusState.pomodoro) {
      return const Color.fromRGBO(186, 73, 73, 1);
    } else if (state == FocusState.shortBreak) {
      return const Color.fromRGBO(56, 133, 138, 1);
    } else {
      return const Color.fromRGBO(57, 112, 151, 1);
    }
  }
}