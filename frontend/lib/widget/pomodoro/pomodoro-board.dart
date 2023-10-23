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
    return Selector<GlobalState, (Task?, List<Task>, FocusState, String)>(
      selector: (_, state) {
        stringOfTimes(Task task) => "${task.finishTime} / ${task.expectTime}";
        final tasks = state.currentTaskGroup!.tasks;
        final s = tasks.map(stringOfTimes).join(",");
        return (state.currentTask, tasks, state.counter.focusState, s);
      },

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
            buildCurrentTask(context),
            buildHead(context),

            SizedBox(height: settings["widget.pomodoro.pomodoro-board.counter.margin-bottom"],),

            Row(mainAxisAlignment: MainAxisAlignment.start, children: [buildSelect(context),],),

            SizedBox(height: settings["widget.pomodoro.pomodoro-board.counter.margin-bottom"],),
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

      child: Container(
        decoration: settings["widget.pomodoro.pomodoro-board.select.decoration"],
        padding: settings["widget.pomodoro.pomodoro-board.select.padding"],
        child: Text(state.currentTaskGroup!.name, style: const TextStyle(color: Colors.white),),
      )
    );

    return Container(
      margin: settings["widget.pomodoro.taskcard.select.margin"],
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("当前任务列表: ", style: TextStyle(fontWeight: FontWeight.bold),),

          popupbutton
        ],
      )
    );
  }

  Widget buildCurrentTask(BuildContext context) {
    return Center(
      child: Text(state.currentTask?.name ?? "", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w100, overflow: TextOverflow.ellipsis),),
    );
  }

  Widget buildHead(BuildContext context) {
    return Container(
      decoration: settings["widget.pomodoro.pomodoro-board.taskheader.decoration"],

      padding: settings["widget.pomodoro.pomodoro-board.taskheader.padding"],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          const Text("Tasks", style: TextStyle(color: Colors.white, fontSize: 18),),

          GestureDetector(
            onTap: () => state.clearActPomodoros(),
            child: Row(
              children: [
                const Icon(Icons.check, color: Colors.white,),
                SizedBox(width: settings["widget.pomodoro.pomodoro-board.taskheader.padding.icon-text"],),
                const Text("Clear act pomodoros", style: TextStyle(color: Colors.white),)
              ],
            ),
          )
        ],
      ),
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
      return settings["widget.pomodoro.pomodoro-board.red"];
    } else if (state == FocusState.shortBreak) {
      return settings["widget.pomodoro.pomodoro-board.green"];
    } else {
      return settings["widget.pomodoro.pomodoro-board.blue"];
    }
  }
}