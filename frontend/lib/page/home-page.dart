import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/widget/home/clipboard.dart';
import 'package:frontend/widget/home/pomodoro.dart';
import 'package:frontend/widget/pages.dart';
import 'package:provider/provider.dart';

/// 这个是主页，主要显示个人资料，番茄钟，剪切板
/// FEATURE: 统计信息展示
class HomePage extends StatelessWidget {
  GlobalState? _state;
  GlobalState get state => _state!;
  set state(GlobalState value) => _state ??= value;

  @override
  Widget build(BuildContext context) {
    state = context.read<GlobalState>();
    List<Widget> actions = [];
    if (!isDesktop) {
      actions = [PopupMenuButton(
          child: const Icon(Icons.more_vert),
          itemBuilder: (_) => [
            PopupMenuItem(
                onTap: () async {
                  await state.logout();
                  state.update();
                },

                child: const Text("退出登录")

            ),

            PopupMenuItem(
              onTap: () async {
                await state.clear();
                state.update();
              },

              child: const Text("重置"),
            )
          ]
      )];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("主页"),
        actions: actions,
      ),
      body: buildBody(context),
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

  Widget buildMobile(BuildContext context) {
    return Pages(children: [
      Center(child: Pomodoro()),
      Center(child: ClipboardWidget())
    ]);
  }
}