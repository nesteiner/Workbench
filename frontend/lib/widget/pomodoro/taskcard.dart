import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  Task task;
  int taskgroupIndex;
  bool isselected;
  late void Function(void Function()) setStateColor;

  late TodoListState state;

  TaskCard({required this.task, required this.isselected, required this.taskgroupIndex});

  @override
  Widget build(BuildContext context) {
    state = context.read<TodoListState>();

    final child0 = StatefulBuilder(builder: (context, setState) {
      setStateColor = setState;

      final text = Text(
        task.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: task.isdone ? Colors.grey : Colors.black,
          decoration: task.isdone ? TextDecoration.lineThrough : null
        ),
      );

      final row = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          text,
          Text("${task.finishTime}/${task.expectTime}", style: settings["widget.pomodoro.taskcard.count.text-style"],)
        ],
      );

       return Container(
         width: settings["widget.pomodoro.counter.width.desktop"],
         padding: settings["widget.pomodoro.taskcard.padding"],
         margin: settings["widget.pomodoro.taskcard.margin"],
         color: Colors.white,
         child: row,
      );


    });

    late Widget child1;

    if (isselected) {
      child1 = Stack(
        children: [
          child0,
          Positioned(
            left: 0,
            // top: settings["widget.pomodoro.taskcard.padding.top"],
            // bottom: 0,
            top: 0,
            bottom: settings["widget.pomodoro.taskcard.padding.bottom"],
            child: Container(
              color: Colors.black,
              width: settings["widget.pomodoro.taskcard.selected.width"],
            ),
          )
        ],
      );
    } else {
      child1 = child0;
    }


    return GestureDetector(
      onTap: () {
        state.setCounterTask(task);
      },

      child: Align(
        alignment: Alignment.center,
        child: child1,
      )
    );
  }

}