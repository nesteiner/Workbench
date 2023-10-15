import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widget/pomodoro/pomodoro-board.dart';
import 'package:frontend/widget/todolist/task.dart';
import 'package:provider/provider.dart';

class TaskGroupWidget extends StatelessWidget {
  TaskGroup taskgroup;
  late GlobalState state;

  TaskGroupWidget({super.key, required this.taskgroup});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    state = context.read<GlobalState>();
    final body = Column(
      children: [
        buildHead(context),
        buildTaskAdd(context),

        Expanded(
            child: SingleChildScrollView(
              child: Selector<GlobalState, String>(
                selector: (_, state) {
                  stringOfTag(Tag tag) => "${tag.id}-${tag.name}";
                  return taskgroup.tasks.map((e) => "${e.id}-${e.name}-${e.isdone}-${(e.tags ?? []).map(stringOfTag).join(",")}").join(",");
                },

                builder: (_, value, child) {
                  return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: taskgroup.tasks.length,
                      itemBuilder: (context, index) => TaskWidget(task: taskgroup.tasks[index], taskgroupIndex: taskgroup.index,)
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
    final name = Selector<GlobalState, String>(
      selector: (_, state) => taskgroup.name,
      builder: (_, value, child) => Text(value, style: const TextStyle(fontWeight: FontWeight.bold),),
    );

    final count = Selector<GlobalState, int>(
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
        showDialog(context: context, builder: (context) => AlertDialog(
          content: PomodoroBoard(),
        ));
      },
      child: SvgPicture.asset("assets/pomodoro.svg", width: settings["common.svg.size"], height: settings["common.svg.size"],),
    );

    final row = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(children: [name, SizedBox(width: 12,), count],),
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
              // TODO later to use state to add this task

              final request = PostTaskRequest(
                  name: controller.text,
                  parentid: taskgroup.id,
                  priority: NORMAL_PRIORITY,
                  expectTime: 4
              );

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
        child = entry;
      }
      
      return child;
      
    });
  }

  void onTapEdit(BuildContext context) {
    final controller = TextEditingController(text: taskgroup.name);
    final disabled = ValueNotifier(true);
    final actions = [
      TextButton(
        onPressed: () {
          navigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      ListenableBuilder(listenable: disabled, builder: (context, child) {
        return TextButton(
          onPressed: disabled.value ? null : () async {
            // TODO
            final request = UpdateTaskGroupRequest(id: taskgroup.id, name: controller.text);
            await state.updateTaskGroup(request, taskgroup.index - 1);

            navigatorKey.currentState?.pop();
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

    final title = const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("编辑这个任务列表", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );

    showDialog(context: context, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions,
    ));
  }

  void onTapAddAfter(BuildContext context) {
    final controller = TextEditingController();
    final disabled = ValueNotifier(true);
    final actions = [
      TextButton(
        onPressed: () {
          navigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      ListenableBuilder(listenable: disabled, builder: (context, child) {
        return TextButton(
          onPressed: disabled.value ? null : () async {
            final request = PostTaskGroupRequest(parentid: state.currentProject!.id, name: controller.text);
            await state.insertTaskGroupAfter(request, taskgroup.index - 1);
            navigatorKey.currentState?.pop();
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

    final title = const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("在此之后添加任务列表", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );

    showDialog(context: context, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions,
    ));

  }

  void onTapDelete(BuildContext context) {
    final actions = [
      TextButton(
        onPressed: () {
          navigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      TextButton(
        onPressed: () async {
          await state.deleteTaskGroup(taskgroup.id);
          navigatorKey.currentState?.pop();
        },

        child: const Text("确定"),
      )
    ];

    final content = const Text("确定删除这个列表? 这个操作无法撤消");

    final title = const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("删除这个任务列表", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );

    showDialog(context: context, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions,
    ));
  }
}