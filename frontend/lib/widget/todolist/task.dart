import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/page/todolist/taskdetail.dart';
import 'package:frontend/utils.dart';

class TaskWidget extends StatefulWidget {
  Task task;
  int taskgroupIndex;

  TaskWidget({required this.task, required this.taskgroupIndex});

  @override
  TaskWidgetState createState() => TaskWidgetState();
}

class TaskWidgetState extends State<TaskWidget> {
  bool ishover = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskDetail(task: widget.task, taskgroupIndex: widget.taskgroupIndex)));
      },

      child: buildCard(context),
    );
  }

  Widget buildCard(BuildContext context) {
    final checkbox =  Checkbox(
        value: widget.task.isdone,
        onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              widget.task.isdone = value;
            });
          }
        });

    final left = SizedBox(
      width: 44,
      height: 48,
      child: Center(
        child: checkbox,
      ),
    );

    final flag = widget.task.subtasks != null && widget.task.subtasks!.length > 0;
    final text = Text(widget.task.name, style: widget.task.isdone ? TextStyle(color: HexColor.fromHex("#8c8c8c")) : null,);

    Widget taskContent = Padding(
      padding: const EdgeInsets.only(top: 14, right: 16, bottom: 14, left: 0),
      child: text
    );

    if (flag) {
      int subtaskCount = widget.task.subtasks!.length;
      int subtaskDoneCount = widget.task.subtasks!.where((element) => element.isdone).length;

      final color = Color.fromRGBO(0, 0, 0, 0.3);
      final subtaskPart = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: settings["widget.task.subtask.decoration"],
            child: Row(
              children: [
                Icon(Icons.list, color: color,),
                Text("$subtaskDoneCount/$subtaskCount", style: TextStyle(color: color),)
              ],
            ),
          )
        ],
      );

      taskContent = Padding(
          padding: const EdgeInsets.only(top: 14, right: 16, bottom: 14, left: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              SizedBox(height: 8,),
              subtaskPart
            ],
          )
      );
    }

    final body = Container(
      width: settings["widget.task.width"],

      constraints: BoxConstraints(
        minHeight: settings["widget.task.height"],
      ),

      // margin: const EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: settings["widget.task.border-radius"],
        boxShadow: [
          settings["widget.task.box-shadow"]
        ]
      ),

      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          Expanded(
            child: taskContent,
          )
        ],
      ),
    );


    // use stack to use left line width
    final stack =  StatefulBuilder(builder: (context, setState) {

      return MouseRegion(
        onEnter: (_) => setState(() { ishover = true; }),
        onExit: (_) => setState(() { ishover = false; }),
        child: Stack(
          children: [
            body,
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: _leftline(),
            )
          ],
        ),
      );
    });

    return Container(
      margin: settings["widget.task.margin"],
      child: stack,
    );
  }



  Widget _leftline() {
    final getwidget = (Color color, double width) => Container(
      width: width,
      decoration: BoxDecoration(
          color: color,
          borderRadius: settings["widget.task.left-line.border-radius"]
      ),

    );

    if (ishover) {
      if (widget.task.priority == LOW_PRIORITY) {
        return getwidget(Colors.grey, settings["widget.task.left-line.hover.width"]);
      } else if (widget.task.priority == NORMAL_PRIORITY) {
        return getwidget(Colors.blue, settings["widget.task.left-line.hover.width"]);
      } else if (widget.task.priority == HIGH_PRIORITY) {
        return getwidget(Colors.red, settings["widget.task.left-line.hover.width"]);
      } else {
        return Container();
      }
    } else {
      if (widget.task.priority == LOW_PRIORITY) {
        return Container();
      } else if (widget.task.priority == NORMAL_PRIORITY) {
        return getwidget(Colors.blue, settings["widget.task.left-line.width"]);
      } else if (widget.task.priority == HIGH_PRIORITY) {
        return getwidget(Colors.red, settings["widget.task.left-line.width"]);
      } else {
        return Container();
      }
    }
  }
}

