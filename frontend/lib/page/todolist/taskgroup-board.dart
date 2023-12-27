import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widget/pages.dart';
import 'package:frontend/widget/pomodoro/pomodoro-board.dart';
import 'package:frontend/widget/todolist/imageuploder.dart';
import 'package:frontend/widget/todolist/taskgroup.dart';
import 'package:provider/provider.dart';

class TaskGroupBoard extends StatelessWidget {
  TodoListState? _state;
  TodoListState get state => _state!;
  set state(TodoListState value) => _state ??= value;

  final TaskProject taskproject;
  late void Function(void Function()) setStateName;

  String? localImagePath;

  TaskGroupBoard({required this.taskproject});

  @override
  Widget build(BuildContext context) {
    state = context.read<TodoListState>();

    late Widget body;

    if (isDesktop) {
      body = buildDesktop(context);
    } else {
      body = buildMobile(context);
    }

    // TODO: implement build
    return Scaffold(
      appBar: buildAppBar(context),
      body: body,
      floatingActionButton: buildFloatingActionButton(context),
      resizeToAvoidBottomInset: false,
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    final title = StatefulBuilder(builder: (context, setState) {
      setStateName = setState;
      return Text(taskproject.name);
    });


    final menubutton = PopupMenuButton(
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.menu),
        ],
      ),

      itemBuilder: (_) => [
        PopupMenuItem(
          onTap: () {
            showDialog(context: context, useRootNavigator: false, builder: (context) => buildEditTaskProject(context) );
          },

          child: buildMenuRow(context, Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/paper.svg", width: settings["common.svg.size"], height: settings["common.svg.size"],),
              SizedBox(width: settings["page.taskgroup-board.appbar.menu.icon.margin"],),
              const Text("项目信息")
            ],
          )),
        ),

        PopupMenuItem(
          onTap: () {
            showDialog(context: context, useRootNavigator: false, builder: (_) => buildDeleteTaskProject(context));
          },

          child: buildMenuRow(context, Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/delete.svg", color: Colors.red, width: settings["common.svg.size"], height: settings["common.svg.size"],),
              SizedBox(width: settings["page.taskgroup-board.appbar.menu.icon.margin"],),
              const Text("删除项目", style: TextStyle(color: Colors.red),)
            ],
          )),
        )
      ],
    );

    final pomodoroSettings = GestureDetector(
      onTap: () => onTapPomodoroSetting(context),
      child: const Icon(Icons.settings, color: Colors.red,),
    );

    return AppBar(
      title: title,
      actions: [menubutton, pomodoroSettings],
    );
  }

  Widget buildDesktop(BuildContext context) {
    return Selector<TodoListState, String>(
      // in this way, reorder will not flash
      // any way, don't build expensive widget in builder
      selector: (_, state) => state.taskgroups.map((e) => taskGroupString(e)).join(","),
      shouldRebuild: (oldvalue, newvalue) => oldvalue != newvalue,
      builder: (_, value, child) {
        final children = state.taskgroups.map<Widget>((e) => TaskGroupWidget(key: ValueKey("${e.id}-${e.name}"), taskgroup: e)).toList();
        return StatefulBuilder(builder: (context, setState) {
          return ReorderableListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: children,
              onReorder: (oldindex, newindex) async {
                if (newindex > oldindex) {
                  newindex -= 1;
                }

                setState(() {
                  final child = children.removeAt(oldindex);
                  children.insert(newindex, child);
                });


                await state.reorderTaskGroup(state.taskgroups[oldindex], oldindex, newindex + 1);
                state.update();
              },

              footer: buildFooter(context)
          );
        });

      },
    );
  }

  Widget buildMobile(BuildContext context) {
    return Selector<TodoListState, String>(
      selector: (_, state) => state.taskgroups.map((e) => taskGroupString(e)).join(","),
      builder: (_, value, child) {
        final children = state.taskgroups.map<Widget>((e) => TaskGroupWidget(key: ValueKey("${e.id}-${e.name}"), taskgroup: e)).toList();
        return Pages(children: children);
      },
    );
  }

  Widget buildEditTaskProject(BuildContext context) {
    final nameController = TextEditingController(text: taskproject.name);
    final profileController = TextEditingController(text: taskproject.profile ?? "");
    
    final cover = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("项目封面"),
        ImageUploader(
            image: Image.network(state.todolistImageUrl(taskproject.avatarid), fit: BoxFit.cover,),
            onTap: (path) {
              localImagePath = path;
            }
        )
      ],
    );

    final name = TextField(
      controller: nameController,
      decoration: settings["page.taskgroup-board.appbar.dialog.edit.title.input-decoration"]("项目名称"),
    );
    
    final profile = TextField(
      controller: profileController,
      decoration: settings["page.taskgroup-board.appbar.dialog.edit.profile.input-decoration"]("项目简介"),
      minLines: 4,
      maxLines: 10,
    );

    return AlertDialog(
      content: Container(
        width: settings["page.taskgroup-board.appbar.dialog.edit.width"],
        padding: settings["page.taskgroup-board.appbar.dialog.edit.padding"],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            cover,
            name,
            profile
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            todolistNavigatorKey.currentState?.pop();
            // Navigator.pop(context);
          },

          child: const Text("取消"),
        ),

        TextButton(
          onPressed: () async {
            final request = UpdateTaskProjectRequest(id: taskproject.id);

            if (nameController.text.isNotEmpty) {
              request.name = nameController.text.trim();

              setStateName(() {
                taskproject.name = nameController.text;
              });
            }

            if (profileController.text.isNotEmpty) {
              request.profile = profileController.text.trim();
            }


            // await state.updateTaskProject(request);
            int? avatarid;
            if (localImagePath != null) {
              final avatar = await state.uploadImage(await MultipartFile.fromFile(localImagePath!));
              avatarid = avatar.id;
            }

            if (avatarid != null) {
              request.avatarid = avatarid;
            }

            await state.updateTaskProject(request);

            todolistNavigatorKey.currentState?.pop();
            // Navigator.pop(context);
          },

          child: const Text("确定"),
        )
      ],
    );
  }

  Widget buildDeleteTaskProject(BuildContext context) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.info, color: Colors.red,),
          SizedBox(width: settings["page.taskgroup-board.appbar.dialog.delete.icon.margin"],),
          Text("将项目删除", style: settings["page.taskgroup-board.appbar.dialog.delete.title.font.style"],)
        ],
      ),

      content: Text(
        "确定删除项目 [${taskproject.name}]? 该操作无法撤回",
        style: settings["page.taskgroup-board.appbar.dialog.delete.content.font.style"],
      ),

      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromRGBO(0, 0, 255, 0.2)
            ),
            
            onPressed: () => todolistNavigatorKey.currentState?.pop(),
            child: Text("取消", style: settings["page.taskgroup-board.appbar.dialog.delete.cancel.font.style"],)
        ),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red
          ),
          
          onPressed: () async {
            await state.deleteTaskProject(taskproject.id);
            // navigatorKey.currentState?.popUntil(ModalRoute.withName("/taskproject"));
            // Navigator.pop(context);
            // Navigator.pop(context);
            // Navigator.pop(context);
            todolistNavigatorKey.currentState?.popUntil(ModalRoute.withName(todolistRoutes["taskproject"]!));
          },

          child: Text("删除", style: settings["page.taskgroup-board.appbar.dialog.delete.confirm.font.style"],),
        )
      ],
    );
  }

  Widget buildMenuRow(BuildContext context, Widget child) {
    return Container(
      padding: settings["page.taskgroup-board.appbar.menu.padding"],
      height: settings["page.taskgroup-board.appbar.menu.height"],
      width: settings["page.taskgroup-board.appbar.menu.width"],
      child: child,
    );
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return Selector<TodoListState, bool>(
      selector: (_, state) => state.timer?.isActive ?? false,
      builder: (_, value, child) {
        if (value) {
          return Selector<TodoListState, String>(
            selector: (_, state) => state.counter.timeText,
            builder: (_, value, child) {
              return FloatingActionButton(
                  onPressed: () {
                    todolistNavigatorKey.currentState?.pushNamed(todolistRoutes["pomodoro"]!);
                  },

                  child: Center(
                    child: Text(value, style: const TextStyle(color: Colors.white),),
                  )
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget buildFooter(BuildContext context) {
    return Container(
      padding: settings["widget.taskgroup.padding"],
      width: settings["widget.taskgroup.width"],
      child: Column(
        children: [
          SizedBox(
            height: settings["widget.taskgroup.head.height"],
            child: TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => insertTaskGroup(context),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey,),
                    Text("新建任务列表", style: TextStyle(color: Colors.grey),)
                  ],
                )
            ),
          ),

          const Expanded(child: SizedBox.shrink())
        ],
      ),
    );
  }

  Future<bool> loadTaskGroup() async {
    await state.setCurrentTaskProject(taskproject);
    return true;
  }

  Future<void> uploadImage(String path) async {
    final multipartfile = await MultipartFile.fromFile(path);
    await state.uploadImage(multipartfile);
  }

  void insertTaskGroup(BuildContext context) {
    const title = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("新建任务列表")
      ],
    );

    final controller = TextEditingController();
    final disabled = ValueNotifier(true);

    final content = TextField(
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "输入任务列表名称"
      ),

      onChanged: (String? value) {
        if (value?.isEmpty ?? true) {
          disabled.value = true;
        } else {
          disabled.value = false;
        }
      },
    );

    actions(BuildContext context) => [
      TextButton(
        onPressed: () {
          todolistNavigatorKey.currentState?.pop();
          // Navigator.pop(context);
        },

        child: const Text("取消"),
      ),

      ListenableBuilder(listenable: disabled, builder: (context, child) => TextButton(
        onPressed: disabled.value ? null : () async {
          final request = PostTaskGroupRequest(parentid: state.currentProject!.id, name: controller.text.trim());
          await state.insertTaskGroup(request);
          todolistNavigatorKey.currentState?.pop();
          // Navigator.pop(context);
        },

        child: const Text("确定"),
      ))

    ];

    showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions(context),
    ));
  }

  void onTapPomodoroSetting(BuildContext context) {
    const title = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(children: [
          Text("设置番茄钟时间")
        ],)
      ],
    );

    final content = Selector<TodoListState, String>(
      selector: (_, state) => "${state.counter.pomodoroTime}-${state.counter.shortBreakTime}-${state.counter.longBreakTime}-${state.counter.longBreakInterval}",
      builder: (_, value, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pomodoro Time"),
              Slider(
                value: state.counter.pomodoroTime.toDouble(),
                min: 15,
                max: 50,
                divisions: 7,
                label: "${state.counter.pomodoroTime}",
                onChanged: (value) {
                  state.setTimes(pomodoroTime: value.toInt());
                },
              )
            ],
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ShortBreak Time"),
              Slider(
                value: state.counter.shortBreakTime.toDouble(),
                min: 5,
                max: 15,
                divisions: 5,
                label: "${state.counter.shortBreakTime}",
                onChanged: (value) {
                  state.setTimes(shortBreakTime: value.toInt());
                },
              )
            ],
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("LongBreak Time"),
              Slider(
                value: state.counter.longBreakTime.toDouble(),
                min: 15,
                max: 25,
                divisions: 5,
                label: "${state.counter.longBreakTime}",
                onChanged: (value) {
                  state.setTimes(longBreakTime: value.toInt());
                },
              )
            ],
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Long Break Interval"),
              Slider(
                value: state.counter.longBreakInterval.toDouble(),
                min: 1,
                max: 10,
                divisions: 10,
                label: "${state.counter.longBreakInterval}",
                onChanged: (value) {
                  state.setTimes(longBreakInterval: value.toInt());
                },
              )
            ],
          )
        ],
      )
    );

    actions(BuildContext context) => [
      TextButton(
        onPressed: () {
          state.resetTimes();
          todolistNavigatorKey.currentState?.pop();
          // Navigator.pop(context);
        },

        child: const Text("reset"),
      ),

      TextButton(
        onPressed: () {
          todolistNavigatorKey.currentState?.pop();
          // Navigator.pop(context);
        },

        child: const Text("cancel"),
      ),
    ];

    showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions(context),
    ));
  }

  String taskGroupString(TaskGroup taskGroup) {
    // final taskString = taskGroup.tasks.map((task) => "${task.id}-${task.name}-${task.isdone}").join(",");
    // return "${taskGroup.id}-${taskGroup.name}-$taskString";
    return "${taskGroup.id}-${taskGroup.name}";
  }
}