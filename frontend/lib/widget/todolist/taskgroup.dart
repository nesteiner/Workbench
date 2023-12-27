import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widget/pomodoro/pomodoro-board.dart';
import 'package:frontend/widget/todolist/task.dart';
import 'package:provider/provider.dart';

class TaskGroupWidget extends StatelessWidget {
  final TaskGroup taskgroup;
  TodoListState? _state;
  TodoListState get state => _state!;
  set state(TodoListState value) => _state ??= value;
  TaskGroupWidget({super.key, required this.taskgroup});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    state = context.read<TodoListState>();
    final body = Column(
      children: [
        buildHead(context),
        buildTaskAdd(context),

        Expanded(
            child: SingleChildScrollView(
              child: Selector<TodoListState, String>(
                selector: (_, state) {
                  stringOfTag(Tag tag) => "${tag.id}-${tag.name}";

                  final s1 = "${taskgroup.id}-${taskgroup.name}";
                  final s2 = taskgroup.tasks.map((e) => "${e.id}-${e.name}-${e.isdone}-${(e.tags ?? []).map(stringOfTag).join(",")}-${e.note}").join(",");
                  return "${s1}-${s2}";
                },

                builder: (_, value, child) {
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: taskgroup.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskgroup.tasks[index];
                        final taskgroupIndex = taskgroup.index;
                        final child = Material(
                          child: TaskWidget(task: task)

                        );

                        return Stack(
                          children: [
                            buildTaskWidgetDrag(context, task, child),
                            buildTaskWidgetDragTarget(context, task, child),
                          ],
                        );
                      }
                  );
                },
              )
            )
        )

      ],
    );

    return Container(
      width: settings["widget.taskgroup.width"],
      child: Padding(
        padding: settings["widget.taskgroup.padding"],
        child: body,
      ),
    );
  }

  Widget buildHead(BuildContext context) {
    // final name = Text(taskgroup.name, style: TextStyle(fontWeight: FontWeight.bold),);
    // final count = Text(taskgroup.tasks.length.toString(), style: TextStyle(fontSize: 12, color: HexColor.fromHex("#bfbfbf")),);
    final name = Selector<TodoListState, String>(
      selector: (_, state) => taskgroup.name,
      builder: (_, value, child) => Text(value, style: const TextStyle(fontWeight: FontWeight.bold),),
    );

    final count = Selector<TodoListState, int>(
      selector: (_, state) => taskgroup.tasks.length,
      builder: (_, value, child) => Text(value.toString(), style: TextStyle(fontSize: 12, color: HexColor.fromHex("#bfbfbf")),),
    );

    final options = PopupMenuButton(
      child: const Icon(Icons.more_horiz),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => onTapEdit(context),
          child: const Row(
            children: [
              Icon(Icons.edit),
              Text("编辑任务列表")],
          ),
        ),

        PopupMenuItem(
          onTap: () => onTapAddAfter(context),
          child: const Row(
            children: [
              Icon(Icons.add),
              Text("在此后新建任务列表")
            ],
          ),
        ),

        PopupMenuItem(
          onTap: () => onTapDelete(context),
          child: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red,),
              Text("删除任务列表")
            ],
          ),
        )
      ],
    );

    final pomodoroButton = GestureDetector(
      onTap: () {
        state.setCounterTaskGroup(taskgroup);
        // showDialog(context: context, builder: (context) => AlertDialog(
        //   content: PomodoroBoard(),
        // ));

        // navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => PomodoroBoard()));
        todolistNavigatorKey.currentState?.pushNamed(todolistRoutes["pomodoro"]!);
      },
      child: SvgPicture.asset("assets/pomodoro.svg", width: settings["common.svg.size"], height: settings["common.svg.size"],),
    );

    final row = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(children: [name, const SizedBox(width: 12,), count],),
        Row(children: [pomodoroButton, options],)
      ],
    );

    return Container(
      height: settings["widget.taskgroup.head.height"],
      child: row
    );
  }

  Widget buildTaskAdd(BuildContext context) {
    bool toggled = false;
    late void Function(void Function()) setStateToggle;
    final controller = TextEditingController();
    final disabled = ValueNotifier(true);

    final entry = GestureDetector(
      onTap: () {
        setStateToggle(() {
          toggled = true;
        });
      },

      child: Container(
        height: settings["widget.taskgroup.task-add.height"],
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              settings["widget.taskgroup.task-add.box-shadow"]
            ]
        ),

        margin: settings["widget.taskgroup.task-add.margin"],

        child: const Center(
            child: Icon(Icons.add, color: Color.fromRGBO(0, 0, 0, 0.5),)
        ),
      ),
    );

    final input = TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: "输入标题以新建任务",
        border: OutlineInputBorder()
      ),

      minLines: 3,
      maxLines: 10,

      onChanged: (String? value) {
        if (value?.isEmpty ?? true) {
          disabled.value = true;
        } else {
          disabled.value = false;
        }
      },
    );

    final buttons = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: HexColor.fromHex("#ccecff")
          ),

          onPressed: () {
            setStateToggle(() {
              toggled = false;
            });
          },

          child: Text("取消", style: TextStyle(color: HexColor.fromHex("#1b9aee")),),
        ),

        const SizedBox(width: 8,),

        ListenableBuilder(listenable: disabled, builder: (context, child) {
         return ElevatedButton(
            onPressed: disabled.value ? null : () async {
              final request = PostTaskRequest(
                  name: controller.text.trim(),
                  parentid: taskgroup.id,
                  priority: NORMAL_PRIORITY,
                  expectTime: 4
              );

              controller.text = "";
              await state.insertTask(request);

              setStateToggle(() {
                toggled = false;
              });
            },

            child: const Text("确定", style: TextStyle(color: Colors.white),),
          );
        })
      ],
    );

    final column = Column(
      children: [
        input,
        const SizedBox(height: 16,),

        buttons
      ],
    );

    final expand = Container(
      padding: settings["widget.taskgroup.task-add.expand.padding"],
      margin: settings["widget.taskgroup.task-add.expand.margin"],
      decoration: settings["widget.taskgroup.task-add.expand.decoration"],
      child: column,
    );

    return StatefulBuilder(builder: (context, setState){
      setStateToggle = setState;
      late Widget child;
      
      if (toggled) {
        child = expand; 
      } else {
        // child = entry;
        child = Stack(
          children: [
            entry,
            DragTarget<Task>(
              onWillAccept: (from) => !(from?.index == 1 && from?.parentid == taskgroup.id),
              onAccept: (from) async {
                final oldlistid = from.parentid;
                final oldlist = state.taskgroups.firstWhere((element) => element.id == oldlistid);
                oldlist.tasks.removeWhere((element) => element.id == from.id);

                taskgroup.tasks.forEach((element) => element.index += 1);
                taskgroup.tasks.insert(0, from);

                oldlist.tasks
                    .where((element) => element.index > from.index)
                    .forEach((element) => element.index -= 1);

                from.index = 1;
                from.parentid = taskgroup.id;

                final request = UpdateTaskRequest(id: from.id, reorderAt: 1, parentid: taskgroup.id);
                await state.updateTask(request);
              },

              builder: (context, datas, rejectedData) {
                if (datas.isEmpty) {
                  return Container(
                    height: settings["widget.taskgroup.task-add.height"],
                  );
                }

                return Column(
                  children: [
                    entry,
                    const SizedBox(height: 2,),
                    ...datas.map((e) => Opacity(opacity: 0.5, child: TaskWidget(task: e!))).toList()
                  ],
                );
              },
            )
          ],
        );
      }
      
      return child;
      
    });
  }

  Widget buildTaskWidgetDrag(BuildContext context, Task task, Material child) {
    final size = MediaQuery.of(context).size;

    final feedback = SizedBox(
        width: size.width * 0.95,
        child: Opacity(opacity: 0.5, child: child,)
    );

    return LongPressDraggable<Task>(
      data: task,
      child: child,
      feedback: feedback,
      childWhenDragging: feedback,
    );
  }

  Widget buildTaskWidgetDragTarget(BuildContext context, Task task, Material child) {
    return DragTarget<Task>(
      onWillAccept: (from) => from?.id != task.id,
      onAccept: (from) async {
        final oldlist = state.taskgroups.firstWhere((element) => element.id == from.parentid);
        oldlist.tasks.removeWhere((element) => element.id == from.id);

        final newlist = state.taskgroups.firstWhere((element) => element.id == task.parentid);
        int reorderAt = task.index + 1;

        if (from.parentid == task.parentid) {
          if (from.index < reorderAt) {
            oldlist.tasks
                .where((element) => element.index <= reorderAt && element.index > from.index)
                .forEach((element) => element.index -= 1);

            reorderAt -= 1;
          } else if (from.index > reorderAt) {
            oldlist.tasks
                .where((element) => element.index >= reorderAt && element.index < from.index)
                .forEach((element) => element.index += 1);
          }

        } else {
          oldlist.tasks
              .where((element) => element.index > from.index)
              .forEach((element) => element.index -= 1);

          newlist.tasks
              .where((element) => element.index >= reorderAt)
              .forEach((element) => element.index += 1);
        }

        final request = UpdateTaskRequest(id: from.id, reorderAt: reorderAt, parentid: newlist.id);
        from.parentid = task.parentid;
        from.index = reorderAt;

        newlist.tasks.insert(reorderAt - 1, from);
        await state.updateTask(request);
      },

      builder: (context, datas, rejectedData) {
        if (datas.isEmpty) {
          return Container(
            height: settings["widget.task.height"],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            SizedBox(height: 4,),
            ...datas.map((e) => Opacity(opacity: 0.5, child: TaskWidget(task: e!))).toList()
          ],
        );
      },
    );
  }

  void onTapEdit(BuildContext context) {
    final controller = TextEditingController(text: taskgroup.name);
    final disabled = ValueNotifier(true);
    actions(BuildContext context) => [
      TextButton(
        onPressed: () {
          // Navigator.pop(context);
          todolistNavigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      ListenableBuilder(listenable: disabled, builder: (context, child) {
        return TextButton(
          onPressed: disabled.value ? null : () async {
            // TODO
            final request = UpdateTaskGroupRequest(id: taskgroup.id, name: controller.text);
            await state.updateTaskGroup(request, taskgroup.index - 1);

            // Navigator.pop(context);
            todolistNavigatorKey.currentState?.pop();
          },

          child: const Text("确定"),
        );
      })
    ];

    final content = TextField(
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder()
      ),

      onChanged: (String? value) {
        if (value?.isEmpty ?? true) {
          disabled.value = true;
        } else {
          disabled.value = false;
        }
      },
    );

    const title = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("编辑这个任务列表", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );

    showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions(context),
    ));
  }

  void onTapAddAfter(BuildContext context) {
    final controller = TextEditingController();
    final disabled = ValueNotifier(true);
    actions(BuildContext context) => [
      TextButton(
        onPressed: () {
          // Navigator.pop(context);
          todolistNavigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      ListenableBuilder(listenable: disabled, builder: (context, child) {
        return TextButton(
          onPressed: disabled.value ? null : () async {
            final request = PostTaskGroupRequest(parentid: state.currentProject!.id, name: controller.text);
            await state.insertTaskGroupAfter(request, taskgroup.index - 1);
            // Navigator.pop(context);
            todolistNavigatorKey.currentState?.pop();
          },

          child: const Text("确定"),
        );
      })
    ];

    final content = TextField(
      controller: controller,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "输入名称"
      ),

      onChanged: (String? value) {
        if (value?.isEmpty ?? true) {
          disabled.value = true;
        } else {
          disabled.value = false;
        }
      },
    );

    const title = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("在此之后添加任务列表", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );

    showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions(context),
    ));

  }

  void onTapDelete(BuildContext context) {
    actions(BuildContext context) => [
      TextButton(
        onPressed: () {
          // Navigator.pop(context);
          todolistNavigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      TextButton(
        onPressed: () async {
          await state.deleteTaskGroup(taskgroup.id);
          // Navigator.pop(context);
          todolistNavigatorKey.currentState?.pop();
        },

        child: const Text("确定"),
      )
    ];

    final content = const Text("确定删除这个列表? 这个操作无法撤消");

    const title = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("删除这个任务列表", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );

    showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions(context),
    ));
  }
}