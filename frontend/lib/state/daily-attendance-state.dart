import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/daily-attendance-api.dart';
import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/request/daily-attendance.dart';

enum ShowMode {
  persistence,
  consecutive
}

class DailyAttendanceState extends ChangeNotifier implements Api {
  final DailyAttendanceApi api;

  Map<Group, List<DailyAttendanceTask>> tasks = Map();
  ShowMode mode = ShowMode.persistence;

  /// 这里不是可以选取 index 来使列表来代表当前的 task 吗
  /// 这里为什么要新定义一个 currentTask 呢
  /// 这是因为有 TaskWidget(task: task)
  /// state 更新的时候是 list[index] = newtask 这个时候 taskwidget 中的 task 是不会更新的，因为被赋予了新值
  /// 而不是原地更新，所以这里要用一个全局的状态变量来代表当前的 task
  DailyAttendanceTask? currentTask;

  DailyAttendanceState({required this.api});

  @override
  void setToken(String token) {
    api.setToken(token);
  }

  void setCurrentTask(DailyAttendanceTask task) {
    currentTask = task;
    notifyListeners();
  }

  Future<void> insertTask(PostDailyAttendanceTaskRequest request) async {
    final task = await api.insertOne(request);
    tasks[task.group]?.insert(0, task);
    notifyListeners();
  }

  Future<void> deleteTask(DailyAttendanceTask task) async {
    tasks[task.group]?.removeWhere((element) => element.id == task.id);

    currentTask = null;
    notifyListeners();
  }

  Future<void> updateTask(UpdateDailyAttendanceTaskRequest request) async {
    final task1 = await api.updateOne(request);
    List<DailyAttendanceTask>? list0;

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
    notifyListeners();
  }

  Future<void> updateProgress(UpdateProgressRequest request) async {
    final task = await api.updateProgress(request);
    late List<DailyAttendanceTask> list0;
    late int index0;
    for (final key in tasks.keys) {
      final list1 = tasks[key];
      final index1 = list1?.indexWhere((element) => element.id == request.id) ?? -1;

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

    currentTask = null;
    notifyListeners();
  }

  Future<bool> findAllOfCurrentDay() async {
    final result = await api.findAllOfCurrentDay();
    tasks.clear();

    for (final task in result) {
      if (tasks.containsKey(task.group)) {
        tasks[task.group]?.add(task);
      } else {
        tasks[task.group] = [task];
      }
    }

    return true;
  }

  String iconUrl(int id) => "${api.dailyAttendanceUrl}/icon/download/$id";

  Future<ImageItem> uploadImage(MultipartFile file) async {
    return await api.uploadImage(file);
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