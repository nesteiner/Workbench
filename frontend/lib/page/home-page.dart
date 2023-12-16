import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/widget/home/clipboard.dart';
import 'package:frontend/widget/home/pomodoro.dart';

/// 这个是主页，主要显示个人资料，番茄钟，剪切板
/// FEATURE: 统计信息展示
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("主页"),),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: settings["page.home.padding"],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Pomodoro()),

          Expanded(child: ClipboardWidget())
        ],
      ),
    );
  }
}