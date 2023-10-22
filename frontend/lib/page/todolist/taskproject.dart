import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/page/todolist/taskgroup-board.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state.dart';
import 'package:frontend/widget/todolist/imageuploder.dart';
import 'package:frontend/widget/todolist/taskproject.dart';
import 'package:provider/provider.dart';

class TaskProjectPage extends StatelessWidget {
  late GlobalState state;
  @override
  Widget build(BuildContext context) {
    state = context.read<GlobalState>();

    final child = FutureBuilder(
        future: loadTaskProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("error: ${snapshot.error}"),
            );
          }

          if (snapshot.hasData) {
            // return buildBody(context, snapshot.requireData);
            return buildBody(context);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );

    return Scaffold(
      body: child,
    );
  }

  Widget buildBody(BuildContext context) {
    late void Function(void Function()) setStateOrder;
    late List<TaskProject> taskprojects;

    final head = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("全部项目", style: TextStyle(fontWeight: FontWeight.bold),),
        PopupMenuButton(
            child: Row(children: const [Text("排序方式"), SizedBox(width: 10,), Icon(Icons.more_horiz)]),
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

    late Widget child;

    if (Platform.isAndroid || Platform.isIOS) {
      child = Consumer<GlobalState>(builder: (context, state, child) {
        taskprojects = state.taskprojects;

        return StatefulBuilder(builder: (context, setState) {
          setStateOrder = setState;
          return ListView(
            shrinkWrap: true,
            children: taskprojects.map((e) => TaskProjectWidget(taskproject: e)).toList(),
          );
        });
      });
    } else {
      final ratio = 208 / 135;

      child = Consumer<GlobalState>(builder: (context, state, child) {
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

    }


    final column = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        head,
        Divider(),
        Expanded(child: child)
      ],
    );

    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height
        ),
        child: column,
      )
    );
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
    
    final imageselect = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("选择图片"),
        ImageUploader(image: Image.network(await state.todolistDefaultImageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter,), onTap: (path) {
          localImagePath = path;
        },)
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
    
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        imageselect,
        name,
        profile
      ],
    );

    if (!context.mounted) {
      return;
    }

    showDialog(context: context, builder: (context) => AlertDialog(
      
      content: content,
      actions: [
        TextButton(
          onPressed: () {
            navigatorKey.currentState?.pop();
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
            
            final request = PostTaskProjectRequest(userid: state.user.id, name: nameController.text.trim());

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

            navigatorKey.currentState?.pop();
          },
          
          child: const Text("确定"),
        )
      ],
    ));
    
  }
  
}