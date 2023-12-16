import 'dart:io';

import 'package:cron/cron.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/request/daily-attendance.dart';
import 'package:timezone/timezone.dart' as tz;

enum ShowMode {
  // 共坚持了多少天
  persistence,
  // 连续坚持了多少天
  consecutive
}

class DailyAttendanceState extends ChangeNotifier implements Api {
  static final cron = Cron();
  static const details = NotificationDetails(
    linux: LinuxNotificationDetails(),
    android: AndroidNotificationDetails("workbench", "workbench"),
  );

  final DailyAttendanceApi api;
  final FlutterLocalNotificationsPlugin plugin;
  final Map<da.Group, List<da.Task>> tasks = Map();

  ShowMode mode = ShowMode.persistence;
  Map<String, List<da.Task>> tasksOf7Days = Map();
  /// 这里不是可以选取 index 来使列表来代表当前的 task 吗
  /// 这里为什么要新定义一个 currentTask 呢
  /// 这是因为有 TaskWidget(task: task)
  /// state 更新的时候是 list[index] = newtask 这个时候 taskwidget 中的 task 是不会更新的，因为被赋予了新值
  /// 而不是原地更新，所以这里要用一个全局的状态变量来代表当前的 task
  da.Task? currentTask;

  /// 这里是为了在 DateSelectPanel 中选择日期
  List<String> weekdays = [];
  String? currentDay;

  bool get isavailable {
    return currentDay == weekdays.last;
  }

  bool? _notifyAble;
  bool get notifyAble {
    _notifyAble ??= Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    
    return _notifyAble!;
  }
  
  DailyAttendanceState({required this.api, required this.plugin});
    

  @override
  void setToken(String token) {
    api.setToken(token);
  }

  void setCurrentDay(String day) {
    if (currentDay == day) {
      return;
    }

    currentDay = day;

    final list = tasksOf7Days[day]!;

    tasks.clear();
    for (final task in list) {
      final group = task.group;

      if (tasks.containsKey(group)) {
        tasks[group]?.add(task);
      } else {
        tasks[group] = [task];
      }
    }

    notifyListeners();
  }

  void setCurrentTask(da.Task task) {
    currentTask = task;
    notifyListeners();
  }

  Future<void> insertTask(PostDailyAttendanceTaskRequest request) async {
    final task = await api.insertOne(request);
    if (tasks.containsKey(task.group)) {
      tasks[task.group]?.insert(0, task);
    } else {
      tasks[task.group] = [task];
    }

    final now = DateTime.now();
    for (final notifyTime in task.notifyTimes) {
      if (notifyAble) {
        final scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, notifyTime.hour,
            notifyTime.minute);
        plugin.zonedSchedule(
            task.id,
            task.name,
            task.encouragement,
            scheduledDate,
            details,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
        );
      } else {
        cron.schedule(Schedule.parse("${notifyTime.minute} ${notifyTime.hour} * * *"), () {
          plugin.show(task.id, task.name, task.encouragement, null);
        });
      }
    }

    notifyListeners();
  }

  Future<void> deleteTask(da.Task task) async {
    tasks[task.group]?.removeWhere((element) => element.id == task.id);
    await api.deleteOne(task.id);

    // donot change the currentTask
    // currentTask = null;

    plugin.cancel(task.id);

    notifyListeners();
  }

  Future<void> updateTask(UpdateDailyAttendanceTaskRequest request) async {
    final task1 = await api.updateOne(request);
    List<da.Task>? list0;

    for (final entry in tasks.entries) {
      final list1 = entry.value;
      final index = list1.indexWhere((element) => element.id == request.id);

      if (index != -1) {
        list0 = list1 ?? [];
        break;
      }
    }

    if (list0 == null) {
      throw Exception("error: there is no such task in the list");
    }

    final index = list0.indexWhere((element) => element.id == request.id);
    final task0 = list0[index];
    final oldgroup = task0.group;
    final newgroup = task1.group;

    if (oldgroup == newgroup) {
      list0[index] = task1;
    } else {
      list0.removeWhere((element) => element.id == request.id);
      final list1 = tasks[task1.group];
      list1?.insert(0, task1);
    }

    currentTask = task1;

    plugin.cancel(request.id);

    final now = DateTime.now();
    for (final notifyTime in task1.notifyTimes) {
      if (notifyAble) {
        final scheduledDate = tz.TZDateTime(
            tz.local, now.year, now.month, now.day, notifyTime.hour,
            notifyTime.minute);
        plugin.zonedSchedule(
            task1.id,
            task1.name,
            task1.encouragement,
            scheduledDate,
            details,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
        );
      } else {
        cron.schedule(Schedule.parse("${notifyTime.minute} ${notifyTime.hour} * * *"), () {
          plugin.show(task1.id, task1.name, task1.encouragement, null);
        });
      }
    }

    notifyListeners();
  }

  Future<void> updateProgress(UpdateProgressRequest request) async {
    final task = await api.updateProgress(request);
    late List<da.Task> list0;
    late int index0;
    for (final key in tasks.keys) {
      final list1 = tasks[key];
      final index1 = list1?.indexWhere((element) => element.id == request.id) ??
          -1;

      if (index1 != -1) {
        list0 = list1 ?? [];
        index0 = index1;
        break;
      }
    }

    list0[index0] = task;
    currentTask = task;
    notifyListeners();
  }

  Future<void> updateArchive(UpdateArchiveTaskRequest request) async {
    await api.updateArchive(request);

    for (final key in tasks.keys) {
      final list = tasks[key];
      final index = list?.indexWhere((element) => element.id == request.id) ?? -1;

      if (index != -1) {
        list?.removeAt(index);
        break;
      }
    }

    if (request.isarchive) {
      plugin.cancel(request.id);
    }

    currentTask = null;
    notifyListeners();
  }

  Future<bool> findAllOfLatest7Days() async {
    final result = await api.findAllOfLatest7Days();
    tasksOf7Days = result;
    currentDay = tasksOf7Days.keys.last;
    weekdays = tasksOf7Days.keys.toList();

    tasks.clear();
    for (final task in tasksOf7Days[currentDay]!) {
      if (tasks.containsKey(task.group)) {
        tasks[task.group]?.add(task);
      } else {
        tasks[task.group] = [task];
      }
    }

    notifyListeners();

    plugin.cancelAll();

    final tasksOfCurrentDay = await api.findAllOfCurrentDay();
    final now = DateTime.now();
    for (final task in tasksOfCurrentDay) {
      for (final notifyTime in task.notifyTimes) {
        if (notifyAble) {
          final scheduledDate = tz.TZDateTime(
              tz.local, now.year, now.month, now.day, notifyTime.hour,
              notifyTime.minute);
          plugin.zonedSchedule(
              task.id,
              task.name,
              task.encouragement,
              scheduledDate,
              details,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
          );
        } else {
          cron.schedule(Schedule.parse("${notifyTime.minute} ${notifyTime.hour} * * *"), () {
            plugin.show(task.id, task.name, task.encouragement, null);
          });
        }
      }
    }


    return true;
  }

  Future<void> resetCurrentTask() async {
    currentTask = await api.resetToday(currentTask!.id);

    final group = currentTask!.group;
    final list = tasks[group]!;
    final index = list.indexWhere((element) => element.id == currentTask!.id);
    list[index] = currentTask!;

    notifyListeners();
  }

  String iconUrl(int id) => "${api.dailyAttendanceUrl}/icon/download/$id";

  Future<da.ImageItem> uploadImage(MultipartFile file) async {
    return await api.uploadImage(file);
  }

  Future<Map<da.Task, List<da.Progress>>> statisticsWeekly(int offset) async {
    return await api.statisticsWeekly(offset);
  }

  Future<Map<da.Task, List<da.Progress>>> statisticsMonthly(int offset) async {
    return await api.statisticsMonthly(offset);
  }

  void swithMode() {
    if (mode == ShowMode.persistence) {
      mode = ShowMode.consecutive;
    } else {
      mode = ShowMode.persistence;
    }

    notifyListeners();
  }
}