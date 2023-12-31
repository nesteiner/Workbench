import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:provider/provider.dart';

class TaskManage extends StatefulWidget {
  @override
  State<TaskManage> createState() => _TaskManageState();
}

class _TaskManageState extends State<TaskManage> with StateMixin, SingleTickerProviderStateMixin {
  List<da.Task> tasksOfKeeping = [];
  List<da.Task> tasksOfArchived = [];
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dailyAttendanceState = context.read<DailyAttendanceState>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            dailyAttendnaceNavigatorKey.currentState?.pop();
          },
        ),

        title: TabBar(
          controller: controller,
          tabs: const [
            Tab(text: "坚持中"),
            Tab(text: "已归档",)
          ],
        ),
      ),

      body: TabBarView(
        controller: controller,
        children: [
          FutureBuilder(
              future: dailyAttendanceState.findAvailableTasks(false),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  logger.e("error in find available tasks", error: snapshot.error, stackTrace: snapshot.stackTrace);
                  return Center(child: Text(snapshot.error.toString()),);
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }

                tasksOfKeeping = snapshot.requireData..sort();
                return Selector<DailyAttendanceState, int>(
                  selector: (_, state) => tasksOfKeeping.length,
                  builder: (_, value, child) => ListView.builder(
                    itemCount: value,
                    itemBuilder: (context, index) {
                      return buildItem(context, tasksOfKeeping[index]);
                    },
                  ),
                );
              }
          ),

          FutureBuilder(
              future: dailyAttendanceState.findAvailableTasks(true),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  logger.e("error in find available tasks", error: snapshot.error, stackTrace: snapshot.stackTrace);
                  return Center(child: Text(snapshot.error.toString()),);
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }

                tasksOfArchived = snapshot.requireData..sort();
                return Selector<DailyAttendanceState, int>(
                  selector: (_, state) => tasksOfArchived.length,
                  builder: (_, value, child) => ListView.builder(
                    itemCount: value,
                    itemBuilder: (context, index) {
                      return buildItem(context, tasksOfArchived[index]);
                    },
                  ),
                );
              }
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, da.Task task) {
    late Widget icon;
    if (task.icon is da.IconWord) {
      final taskIcon = task.icon as da.IconWord;
      icon = Container(
        width: settings["widget.daily-attendance.task.icon.size"],
        height: settings["widget.daily-attendance.task.icon.size"],
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: taskIcon.color
        ),
        child: Center(
            child: Text(taskIcon.word, style: const TextStyle(color: Colors.white),)
        ),
      );

    } else {
      final taskIcon = task.icon as da.IconImage;

      return Container(
        width: settings["widget.daily-attendance.task.icon.size"],
        height: settings["widget.daily-attendance.task.icon.size"],
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),

        child: Center(child: Image.network(dailyAttendanceState.iconUrl(taskIcon.entryId))),
      );
    }

    late Widget right;
    final deleteButton = IconButton(
      onPressed: () async {
        if (task.isarchived) {
          tasksOfArchived.removeWhere((element) => element.id == task.id);
        } else {
          tasksOfKeeping.removeWhere((element) => element.id == task.id);
        }

        await dailyAttendanceState.deleteTask(task);
      },

      icon: const Icon(Icons.delete, color: Colors.red,),
    );

    if (task.isarchived) {
      right = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              // tasksOfKeeping.removeWhere((element) => element.id == task.id);
              // task.isarchived = true;
              // tasksOfArchived.add(task);
              // tasksOfArchived.sort();

              tasksOfArchived.removeWhere((element) => element.id == task.id);
              task.isarchived = false;
              tasksOfKeeping.add(task);
              tasksOfKeeping.sort();

              final request = UpdateArchiveTaskRequest(id: task.id, isarchive: false);
              await dailyAttendanceState.updateArchive(request);
            },

            icon: const Icon(Icons.refresh),
          ),

          deleteButton
        ],
      );
    } else {
      right = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              // tasksOfArchived.removeWhere((element) => element.id == task.id);
              // task.isarchived = false;
              // tasksOfKeeping.add(task);
              // tasksOfKeeping.sort();
              tasksOfKeeping.removeWhere((element) => element.id == task.id);
              task.isarchived = true;
              tasksOfArchived.add(task);
              tasksOfArchived.sort();

              final request = UpdateArchiveTaskRequest(id: task.id, isarchive: true);
              await dailyAttendanceState.updateArchive(request);
            },

            icon: const Icon(Icons.archive_outlined),
          ),

          deleteButton
        ],
      );
    }

    return Container(
      padding: settings["widget.daily-attendance.task.padding"],
      width: double.infinity,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: settings["widget.daily-attendance.task.icon.margin"],),
              Text(task.name)
            ],
          ),

          right
        ],
      ),
    );
  }
}