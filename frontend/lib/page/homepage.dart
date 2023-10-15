import 'package:flutter/material.dart';
import 'package:frontend/page/todolist/taskproject.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return TaskProjectPage();
  }
}