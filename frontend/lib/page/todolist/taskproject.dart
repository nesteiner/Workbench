import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/page/todolist/taskproject-add.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widget/todolist/imageuploder.dart';
import 'package:frontend/widget/todolist/taskproject.dart';
import 'package:provider/provider.dart';

class TaskProjectPage extends StatelessWidget {
  TodoListState? _state;
  TodoListState get state => _state!;
  set state(TodoListState value) => _state ??= value;

  UserState? _loginState;
  UserState get loginState => _loginState!;
  set loginState(UserState value) => _loginState ??= value;

  @override
  Widget build(BuildContext context) {
    state = context.read<TodoListState>();
    loginState = context.read<UserState>();

    final child = FutureBuilder(
        future: loadTaskProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("error in build TaskProjectPage: ${snapshot.error}"),
            );
          }

          if (snapshot.hasData) {
            // return buildBody(context, snapshot.requireData);
            return buildBody(context);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );

    FloatingActionButton? floatingActionButton;

    if (!isDesktop) {
      floatingActionButton = FloatingActionButton(
        onPressed: () {
          todolistNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskProjectAdd()));
        },

        child: const Icon(Icons.add),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("待办清单"),),
      body: child,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget buildBody(BuildContext context) {
    if (isDesktop) {
      return buildDesktop(context);
    } else {
      return buildMobile(context);
    }
  }

  Widget buildDesktop(BuildContext context) {
    late void Function(void Function()) setStateOrder;
    late List<TaskProject> taskprojects;
    final width = MediaQuery.of(context).size.width;

    final head0 = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("全部项目", style: TextStyle(fontWeight: FontWeight.bold),),
        PopupMenuButton(
            child: const Row(children: [Text("排序方式"), SizedBox(width: 10,), Icon(Icons.more_horiz)]),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  setStateOrder(() {
                    taskprojects.sort((left, right) => left.updateTime.compareTo(right.updateTime) < 0 ? 1 : -1);
                  });
                },

                child: const Text("更新时间"),
              ),

              PopupMenuItem(
                onTap: () {
                  setStateOrder(() {
                    taskprojects.sort((left, right) => left.name.compareTo(right.name) < 0 ? -1 : 1);
                  });
                },


                child: const Text("项目名称"),
              )
            ]
        )
      ],
    );

    final head = SizedBox(
      width: width,
      child: head0,
    );

    late Widget child;

    const ratio = 208 / 135;

    final child0 = Selector<TodoListState, String>(
      selector: (_, state) => state.taskprojects.map((e) => "${e.id}-${e.avatarid}-${e.name}").join(","),
      builder: (_, value, child) {
        taskprojects = state.taskprojects;

        return StatefulBuilder(builder: (context, setState) {
          setStateOrder = setState;

          final children = taskprojects.map<Widget>((e) => TaskProjectWidget(taskproject: e)).toList();
          children.add(buildTaskProjectAdd(context));
          return GridView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: settings["widget.taskproject.max-width"],
                  childAspectRatio: ratio
              ),

              children: children
          );
        });
      },);

    child = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
      ),

      child: child0,
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        head,
        const Divider(),
        Expanded(child: child)
      ],
    );


    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: column,
    );

  }

  Widget buildMobile(BuildContext context) {
    List<TaskProject> taskprojects = [];

    return Selector<TodoListState, String>(
        selector: (_, state) => state.taskprojects.map((e) => "${e.id}-${e.avatarid}-${e.name}").join(","),
        builder: (_, value, child) {
          taskprojects = state.taskprojects;
          return ListView(
            scrollDirection: Axis.vertical,
            children: taskprojects.map((e) => TaskProjectWidget(taskproject: e)).toList(),
          );
        });
  }

  Widget buildTaskProjectAdd(BuildContext context) {
    final add = Padding(
      padding: settings["widget.taskproject.add.icon.padding"],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.add,
            color: settings["widget.taskproject.add.color"],
            size: settings["widget.taskproject.add.icon.size"],
          )
        ],
      ),
    );

    final create = Padding(
      padding: settings["widget.taskproject.add.create.padding"],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("创建项目", style: TextStyle(color: settings["widget.taskproject.add.color"], fontWeight: FontWeight.bold),)
        ],
      ),
    );

    final container = Container(
      constraints: BoxConstraints(
        minWidth: settings["widget.taskproject.min-width"],
        maxWidth: settings["widget.taskproject.max-width"]
      ),
      // height: settings["widget.taskproject.footer.height"] + settings["widget.taskproject.thumbnail.height"],
      decoration: BoxDecoration(
        color: settings["widget.taskproject.add.background-color"],
        borderRadius: settings["widget.taskproject.add.border-radius"],
        boxShadow: [
          settings["widget.taskproject.add.box-shadow"]
        ],
      ),

      margin: settings["widget.taskproject.add.margin"],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          add,
          create
        ],
      ),
    );

    return GestureDetector(
      onTap: () => onTapAdd(context),
      child: container,
    );
  }

  Future<List<TaskProject>> loadTaskProjects() async {
    await state.loadTaskProjects();
    return state.taskprojects;
  }

  Future<void> onTapAdd(BuildContext context) async {
    String? localImagePath;
    final nameController = TextEditingController();
    final profileController = TextEditingController();
    
    final imageselect = Container(
      margin: settings["page.taskproject-add.item.margin"],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("选择图片"),
          ImageUploader(image: Image.network(await state.todolistDefaultImageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter,), onTap: (path) {
            localImagePath = path;
          },)
        ],
      ),
    );
    
    final name = Container(
      margin: settings["page.taskproject-add.item.margin"],
      child: TextField(
        controller: nameController,
        decoration: settings["page.taskgroup-board.appbar.dialog.edit.title.input-decoration"]("项目名称"),
      ),
    );
    
    final profile = Container(
      margin: settings["page.taskproject-add.item.margin"],
      child: TextField(
        controller: profileController,
        decoration: settings["page.taskgroup-board.appbar.dialog.edit.profile.input-decoration"]("项目简介"),
        minLines: 4,
        maxLines: 10,
      ),
    );
    
    final content = Container(
      padding: settings["page.taskproject-add.content.padding"],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imageselect,
          name,
          profile
        ],
      ),
    );

    if (!context.mounted) {
      return;
    }

    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) => AlertDialog(
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.pop(context);
                todolistNavigatorKey.currentState?.pop();
              },

              child: const Text("取消"),
            ),

            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  final snackbar = SnackBar(content: const Text("项目名称不能为空"));
                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  return;
                }

                final request = PostTaskProjectRequest(userid: loginState.userid, name: nameController.text.trim());

                if (profileController.text.isNotEmpty) {
                  request.profile = profileController.text.trim();
                }

                if (localImagePath != null) {
                  final file = await MultipartFile.fromFile(localImagePath!);
                  final imageitem = await state.uploadImage(file);
                  request.avatarid = imageitem.id;
                } else {
                  final imageitem = await state.defaultTodoListImage();
                  request.avatarid = imageitem.id;
                }

                await state.insertTaskProject(request);

                // Navigator.pop(context);
                todolistNavigatorKey.currentState?.pop();
              },

              child: const Text("确定"),
            )
          ],
    ));
    
  }
  
}