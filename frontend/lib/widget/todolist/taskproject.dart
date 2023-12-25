
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/utils.dart';
import 'package:provider/provider.dart';

class TaskProjectWidget extends StatelessWidget {
  final TaskProject taskproject;
  TodoListState? _state;
  TodoListState get state => _state!;
  set state(TodoListState value) => _state ??= value;

  TaskProjectWidget({super.key, required this.taskproject});

  @override
  Widget build(BuildContext context) {
    state = context.read<TodoListState>();

    late Widget container;

    if (isDesktop) {
      container = buildDesktop(context);
    } else {
      container = buildMobile(context);
    }

    return GestureDetector(
      onTap: () async {
        await state.setCurrentTaskProject(taskproject);
        // todolistNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskGroupBoard(taskproject: taskproject)));
        todolistNavigatorKey.currentState?.pushNamed(todolistRoutes["taskgroup-board"]!);
      },
      child: container
    );
  }

  Widget buildDesktop(BuildContext context) {
    final footer = Container(
      decoration: BoxDecoration(
          borderRadius: settings["widget.taskproject.footer.border-radius"],
          color: Colors.white
      ),

      padding: settings["widget.taskproject.footer.padding"],
      height: settings["widget.taskproject.footer.height"],

      child: Row(children: [
        Text(taskproject.name, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),)
      ],),
    );


    return Container(
      constraints: BoxConstraints(
          minWidth: settings["widget.taskproject.min-width"],
          maxWidth: settings["widget.taskproject.max-width"]
      ),

      margin: settings["widget.taskproject.margin"],
      decoration: BoxDecoration(
          color: settings["widget.taskproject.background-color"],
          boxShadow: [
            settings["widget.taskproject.box-shadow"]
          ],
          borderRadius: settings["widget.taskproject.border-radius"],
          image: DecorationImage(
            image: NetworkImage(state.todolistImageUrl(taskproject.avatarid)),
            fit: BoxFit.cover
          )
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          footer,
        ],
      )
    );
  }

  Widget buildMobile(BuildContext context) {
    final image = Image.network(
      state.todolistImageUrl(taskproject.avatarid),
      fit: BoxFit.fitWidth,
    );

    final thumbnail = Container(
        decoration: BoxDecoration(
          borderRadius: settings["widget.taskproject.thumbnail.border-radius.mobile"],
        ),

        width: settings["widget.taskproject.thumbnail.size.mobile"],
        height: settings["widget.taskproject.thumbnail.size.mobile"],

        child: image
    );

    late Widget footer;

    if (taskproject.profile != null) {
      footer = Column(
        children: [
          Row(
            children: [
              Text(
                taskproject.name,
                style: settings["widget.taskproject.thumbnail.text-style"],
                overflow: TextOverflow.ellipsis,
              )
            ],),

          Row(
            children: [
              Text(
                taskproject.profile!,
                style: const TextStyle(
                    fontSize: 14, color: Color.fromRGBO(0, 0, 0, 0.5)
                ),
                overflow: TextOverflow.ellipsis,
              )
            ],
          )
        ],
      );
    } else {
      footer = Column(
          children: [
            Row(
                children: [
                  Text(
                    taskproject.name,
                    style: settings["widget.taskproject.thumbnail.text-style"],
                    overflow: TextOverflow.ellipsis,
                  )
                ]
            )
          ]
      );
    }


    return Container(
      padding: settings["widget.taskproject.padding"],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          thumbnail,
          SizedBox(width: settings["common.unit.size"],),
          footer
        ],
      ),
    );
  }
}