import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/page/todolist/taskdetail.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/utils.dart';
import 'package:provider/provider.dart';

class TaskWidget extends StatefulWidget {
  Task task;
  // index start from 1
  int taskgroupIndex;

  TaskWidget({required this.task, required this.taskgroupIndex});

  @override
  TaskWidgetState createState() => TaskWidgetState();

}

class TaskWidgetState extends State<TaskWidget> {
  late TodoListState state;
  bool ishover = false;

  @override
  Widget build(BuildContext context) {
    state = context.read<TodoListState>();

    return GestureDetector(
      onTap: () {
        state.setCurrentTaskGroupAt(widget.taskgroupIndex - 1);
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskDetail(task: widget.task)));
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


    final text = Text(widget.task.name, style: widget.task.isdone ? TextStyle(color: HexColor.fromHex("#8c8c8c")) : null,);

    Widget taskContent = Padding(
      padding: settings["widget.task.content.padding"],
      child: text
    );

    final color = Color.fromRGBO(0, 0, 0, 0.3);

    late List<Widget> children;

    if (widget.task.subtasks != null && widget.task.subtasks!.length > 0) {
      final attachSubTask = SizedBox(
        height: settings["widget.task.attach.height"],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.list, color: color,),
            Selector<TodoListState, String>(
              selector: (_, state) {
                int subtaskCount = widget.task.subtasks!.length;
                int subtaskDoneCount = widget.task.subtasks!.where((element) => element.isdone).length;
                return "$subtaskDoneCount/$subtaskCount";
              },

              builder: (_, value, child) => Text(value, style: TextStyle(color: color),),
            )
          ],
        ),
      );

      children = [
        ...buildTags(context),
        attachSubTask
      ];

    } else {
      children = buildTags(context);
    }

    if (!(widget.task.note?.isEmpty ?? true)) {
      final noteAttach = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/note.svg", height: settings["widget.task.attach.height"],),
          SizedBox(width: 2,)
        ],
      );

      children.insert(0, noteAttach);
    }

    late Widget taskAttachment;
    if (children.isEmpty) {
      taskAttachment = SizedBox.shrink();
    } else {
      taskAttachment = Container(
        padding: settings["widget.task.attach.padding"],
        child: Wrap(
          direction: Axis.horizontal,
          children: children,
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                taskContent,
                taskAttachment
              ],
            ),
          )
        ],
      ),
    );


    // use stack to use left line width
    final stack = StatefulBuilder(builder: (context, setState) {

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
    getwidget(Color color, double width) => Container(
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
  
  List<Widget> buildTags(BuildContext context) {
    final tags = widget.task.tags ?? [];
    return tags.map((e) => SizedBox(
      height: settings["widget.task.attach.height"],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: e.color.withOpacity(1)),
          ),

          SizedBox(width: 2,),
          Text(e.name, style: TextStyle(fontSize: settings["widget.task.attach.font-size"]),),

          SizedBox(width: 2,)
        ],
      ),
    )).toList();
  }
}

