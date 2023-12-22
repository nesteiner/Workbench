import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:frontend/widget/todolist/imageuploder.dart';
import 'package:provider/provider.dart';

class TaskProjectAdd extends StatelessWidget {
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

    // TODO: implement build
    String? localImagePath;
    final nameController = TextEditingController();
    final profileController = TextEditingController();

    final imageselect = Container(
      margin: settings["page.taskproject-add.item.margin"],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("选择图片"),
          FutureBuilder(
              future: state.todolistDefaultImageUrl,
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  logger.e("error in futurebuild, state.todolistDefaultImageUrl", error: snapshot.error, stackTrace: snapshot.stackTrace);
                  return Center(child: Text(snapshot.error.toString()),);
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }

                return ImageUploader(
                  image: Image.network(snapshot.requireData, fit: BoxFit.cover, alignment: Alignment.topCenter,),
                  onTap: (path) {
                    localImagePath = path;
                  },
                );
              }
          )
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


    final actions = [
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("添加任务列表"),
        actions: actions,
      ),
      body: content,
      resizeToAvoidBottomInset: false,
    );
  }
}