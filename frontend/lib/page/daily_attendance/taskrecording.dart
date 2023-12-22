import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/page/daily_attendance/taskedit.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/widget/daily_attendance/switcher.dart';
import 'package:provider/provider.dart';

/// ATTENTION
/// 这里不用一个 类变量 task 来代表 state.currentTask 的原因是，state.currentTask 要赋予新值，
/// 这个时候 task 无法随之更新
/// ATTENTION
/// fuck you, you can give a getter function
class TaskRecording extends StatelessWidget {
  DailyAttendanceState? _state;
  DailyAttendanceState get state => _state!;
  set state(DailyAttendanceState value) => _state ??= value;

  late final Widget backgroundImage;

  late final ValueNotifier<bool> isdoneNotifier;
  bool get isdone => currentTask.progress == da.ProgressDone();
  da.Task get currentTask => state.currentTask!;
  bool get destroyed => state.currentTask == null;

  @override
  Widget build(BuildContext context) {
    state = context.read<DailyAttendanceState>();
    isdoneNotifier = ValueNotifier(isdone);

    backgroundImage = Selector<DailyAttendanceState, int?>(
      selector: (_, state) {
        int? id;
        if (currentTask.icon is da.IconImage) {
          final icon = currentTask.icon as da.IconImage;
          id = icon.backgroundId;
        }

        return id;
      },

      builder: (_, value, child) {
        if (value == null) {
          // backgroundColor = settings["page.daily-attendance.taskrecording.background.default-color"];

          return Image.asset(
            "assets/record.png",
            width: settings["page.daily-attendance.taskrecording.background.icon.size"],
            height: settings["page.daily-attendance.taskrecording.background.icon.size"],
          );
        } else {
          // backgroundColor = value.$2!;

          return Image.network(
            state.iconUrl(value),
            width: settings["page.daily-attendance.taskrecording.background.icon.size"],
            height: settings["page.daily-attendance.taskrecording.background.icon.size"],
          );
        }
      },
    );

    return Selector<DailyAttendanceState, Color?>(
      selector: (_, state) {
        Color? color;
        if (currentTask.icon is da.IconImage) {
          final icon = currentTask.icon as da.IconImage;
          color = icon.backgroundColor;
        }

        return color;
      },

      builder: (_, value, child) {
        final color = value ?? settings["page.daily-attendance.taskrecording.background.default-color"];
        return Scaffold(
          appBar: buildAppBar(context, color),
          body: buildBody(context, color),
        );
      },
    );
  }

  AppBar buildAppBar(BuildContext context, Color backgroundColor) {
    return AppBar(
      backgroundColor: backgroundColor,

      actions: [
        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
                onTap: () async {
                  await state.resetCurrentTask();
                  isdoneNotifier.value = isdone;
                },
                
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh),
                    SizedBox(width: settings["common.unit.size"],),
                    const Text("重置打卡")
                  ],
                )
            ),
            PopupMenuItem(
              onTap: () {
                dailyAttendnaceNavigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => TaskEdit()));
              },
              
              child: SizedBox(
                  width: settings["page.daily-attendance.taskrecoring.menu.width"],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, color: Colors.black,),
                      SizedBox(width: settings["common.unit.size"],),
                      const Text("编辑")
                    ],
                  ),
              ),
            ),

            PopupMenuItem(
                onTap: () async {
                  final request = UpdateArchiveTaskRequest(id: currentTask.id, isarchive: true);
                  await state.updateArchive(request);
                },

                child: SizedBox(
                  width: settings["page.daily-attendance.taskrecoring.menu.width"],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.archive_outlined, color: Colors.black,),
                      SizedBox(width: settings["common.unit.size"]),
                      const Text("归档")
                    ],
                  ),
                )
            ),

            PopupMenuItem(
              onTap: () {
                actions(BuildContext context1) => [
                  TextButton(
                    onPressed: () {
                      // dailyAttendnaceNavigatorKey.currentState?.pop();
                      Navigator.pop(context1);
                    },

                    child: const Text("取消"),
                  ),

                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context1);
                      dailyAttendnaceNavigatorKey.currentState?.popUntil(ModalRoute.withName(dailyAttendanceRoutes["taskpage"]!));
                      await state.deleteTask(currentTask);
                    },

                    child: const Text("确定"),
                  )
                ];


                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("删除习惯"),
                  content: const Text("确定删除这个习惯? 这个操作无法恢复"),
                  actions: actions(context),
                ));
              },

              child: SizedBox(
                width: settings["page.daily-attendance.taskrecoring.menu.width"],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_forever_outlined, color: Colors.black,),
                    SizedBox(width: settings["common.unit.size"],),
                    const Text("删除")
                  ],
                ),
              )
            )
          ],

          child: const Icon(Icons.more_vert),
        )
      ],
    );
  }

  Widget buildBody(BuildContext context, Color backgroundColor) {
    final task = currentTask;

    final switcher = Selector<DailyAttendanceState, da.Task>(
      selector: (_, state) => currentTask,
      builder: (_, datask, child) {
        return Switcher(
            duration: const Duration(milliseconds: 500),
            value: datask.progress == da.ProgressDone(),
            onChanged: (boolvalue) async {
              late UpdateProgressRequest request;
              if (boolvalue) {

                if (datask.goal is da.GoalCurrentDay) {
                  request = UpdateProgressRequest(id: datask.id, progress: da.ProgressDone());
                } else if (datask.goal is da.GoalAmount) {
                  final goal = datask.goal as da.GoalAmount;
                  final progress = datask.progress;
                  if (progress is da.ProgressReady) {
                    request = UpdateProgressRequest(id: datask.id, progress: da.ProgressDoing(total: goal.total, unit: goal.unit, amount: goal.eachAmount));
                  } else if (progress is da.ProgressDoing) {
                    final progress1 = progress as da.ProgressDoing;
                    request = UpdateProgressRequest(id: datask.id, progress: da.ProgressDoing(total: goal.total, unit: goal.unit, amount: progress1.amount + goal.eachAmount));
                  }

                }
              } else {
                if (datask.goal is da.GoalCurrentDay) {
                  request = UpdateProgressRequest(id: datask!.id, progress: da.ProgressReady());
                } else if (datask.goal is da.GoalAmount) {
                  final goal = datask.goal as da.GoalAmount;
                  final progress = datask.progress;
                  if (progress is da.ProgressDoing || progress is da.ProgressDone) {
                    request = UpdateProgressRequest(id: datask.id, progress: da.ProgressDoing(total: goal.total, unit: goal.unit, amount: goal.total - goal.eachAmount));
                  }
                }
              }

              await state.updateProgress(request);
              isdoneNotifier.value = isdone;
            }
        );
      },
    );

    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: BoxDecoration(
        color: backgroundColor
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          backgroundImage,
          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.0"],),
          Text(task.name, style: TextStyle(color: settings["page.daily-attendance.taskrecording.font.color"], fontSize: settings["page.daily-attendance.taskrecording.font.title.size"]),),
          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.1"],),
          Text(task.encouragement, style: TextStyle(color: settings["page.daily-attendance.taskrecording.font.color"], fontSize: settings["page.daily-attendance.taskrecording.font.encouragement.size"]),),
          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.2"],),

          ValueListenableBuilder(
              valueListenable: isdoneNotifier,
              builder: (context, value, child) {
                return Visibility(
                    visible: !value,
                    maintainSize: true,
                    maintainState: true,
                    maintainAnimation: true,
                    child: switcher
                );
              }
          ),

          SizedBox(height: settings["page.daily-attendance.taskrecording.margin.3"],),

          Selector<DailyAttendanceState, (bool, double?)>(
            selector: (_, state) {
              final $1 = currentTask.progress is da.ProgressDoing;
              late double? $2;

              if (currentTask.progress is da.ProgressDone) {
                $2 = 1;
              } else if (currentTask.progress is! da.ProgressDoing) {
                $2 = null;
              } else {
                final progress = currentTask.progress as da.ProgressDoing;
                $2 = progress.amount / progress.total;
              }

              return ($1, $2);
            },

            builder: (_, value, child) {
              if (!value.$1 || value.$2 == null) {
                return const SizedBox.shrink();
              }

              return FractionallySizedBox(
                widthFactor: 0.5,
                child: LinearProgressIndicator(
                  value: value.$2,
                ),
              );
            },
          )

        ],
      ),

    );
  }
}