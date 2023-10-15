import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/pomodoro.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state.dart';
import 'package:frontend/widget/pomodoro/pomodoro-board.dart';
import 'package:frontend/widget/todolist/imageuploder.dart';
import 'package:frontend/widget/todolist/taskgroup.dart';
import 'package:provider/provider.dart';

class TaskGroupBoard extends StatelessWidget {
  late GlobalState state;
  TaskProject taskproject;
  late void Function(void Function()) setStateName;

  String? localImagePath;

  TaskGroupBoard({required this.taskproject});

  @override
  Widget build(BuildContext context) {
    state = context.read<GlobalState>();
    // TODO: implement build
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    final title = StatefulBuilder(builder: (context, setState) {
      setStateName = setState;
      return Text(taskproject.name);
    });


    final menubutton = PopupMenuButton(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.menu),
          Text("菜单", style: TextStyle(color: settings["page.taskgroup-board.appbar.font.color"]),)
        ],
      ),

      itemBuilder: (_) => [
        PopupMenuItem(
          onTap: () {
            showDialog(context: context, builder: (context) => buildEditTaskProject(context) );
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
            showDialog(context: context, builder: (_) => buildDeleteTaskProject(context));
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

    return AppBar(
      title: title,
      actions: [menubutton],
    );
  }

  Widget buildBody(BuildContext context) {
    return FutureBuilder(
        future: loadTaskGroup(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("error: ${snapshot.error}");
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(),);
          }


          // final children = state.taskgroups.map<Widget>((e) => TaskGroupWidget(key: ValueKey("taskgroup-${e.id}"), taskgroup: e)).toList();
          return Selector<GlobalState, String>(
            // in this way, reorder will not flash
            // any way, don't build expensive widget in builder
            selector: (_, state) => state.taskgroups.map((e) => "${e.id}-${e.name}").join(","),
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
                    },

                    footer: buildFooter(context)
                );
              });

            },
          );
        }
    );
  }

  Widget buildTaskGroupAdd(BuildContext context) {
    return Container(
      padding: settings["page.taskgroup-board.items.padding"],
      width: settings["page.taskgroup-board.width"],

      child: Column(
        mainAxisSize: MainAxisSize.max,

        children: [
          SizedBox(
            height: settings["widget.taskgroup.head.height"],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: settings["page.taskgroup-board.add.icon.margin"],
                  child: Icon(Icons.add, color: settings["page.taskgroup-board.add.font.color"],),
                ),

                Text("新建任务列表", style: TextStyle(color: settings["page.taskgroup-board.add.font.color"]),)
              ]
            ),
          )
        ],
      ),
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

    final name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("项目名称"),
        TextField(
          controller: nameController,
          decoration: settings["page.taskgroup-board.appbar.dialog.edit.title.input-decoration"],
        )
      ],
    );
    
    final profile = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("项目简介"),
        TextField(
          controller: profileController,
          decoration: settings["page.taskgroup-board.appbar.dialog.edit.profile.input-decoration"],
          minLines: 4,
          maxLines: 10,
        )
      ],
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
            navigatorKey.currentState?.pop();
          },

          child: const Text("取消"),
        ),

        TextButton(
          onPressed: () async {
            final request = UpdateTaskProjectRequest(id: taskproject.id);

            if (nameController.text.isNotEmpty) {
              request.name = nameController.text;

              setStateName(() {
                taskproject.name = nameController.text;
              });
            }

            if (profileController.text.isNotEmpty) {
              request.profile = profileController.text;
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

            navigatorKey.currentState?.pop();
          },

          child: const Text("确定"),
        )
      ],
    );
  }

  Widget buildDeleteTaskProject(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
              foregroundColor: Color.fromRGBO(0, 0, 255, 0.2)
            ),
            
            onPressed: () => navigatorKey.currentState?.pop(), 
            child: Text("取消", style: settings["page.taskgroup-board.appbar.dialog.delete.cancel.font.style"],)
        ),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red
          ),
          
          onPressed: () async {
            await state.deleteTaskProject(taskproject.id);
            navigatorKey.currentState?.popUntil(ModalRoute.withName("/taskproject"));
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
    return Selector<GlobalState, bool>(
      selector: (_, state) => state.timer?.isActive ?? false,
      builder: (_, value, child) {
        if (value) {
          return Selector<GlobalState, String>(
            selector: (_, state) => state.counter.timeText,
            builder: (_, value, child) {
              return FloatingActionButton(
                  onPressed: () {
                    showDialog(context: context, builder: (context) =>
                        AlertDialog(
                          content: PomodoroBoard(),
                        ));
                  },

                  child: Center(
                    child: Text(value, style: TextStyle(color: Colors.white),),
                  )
              );
            },
          );
        } else {
          return SizedBox.shrink();
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
    final title = const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("新建任务列表")
      ],
    );

    final controller = TextEditingController();
    final disabled = ValueNotifier(true);

    final content = TextField(
      controller: controller,
      decoration: InputDecoration(
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

    final actions = [
      TextButton(
        onPressed: () {
          navigatorKey.currentState?.pop();
        },

        child: const Text("取消"),
      ),

      ListenableBuilder(listenable: disabled, builder: (context, child) => TextButton(
        onPressed: disabled.value ? null : () async {
          final request = PostTaskGroupRequest(parentid: state.currentProject!.id, name: controller.text);
          await state.insertTaskGroup(request);
          navigatorKey.currentState?.pop();
        },

        child: const Text("确定"),
      ))

    ];

    showDialog(context: context, builder: (context) => AlertDialog(
      title: title,
      content: content,
      actions: actions,
    ));
  }
}