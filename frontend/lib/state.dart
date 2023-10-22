import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api.dart';
import 'package:frontend/model/login.dart';
import 'package:frontend/model/pomodoro.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';

class GlobalState extends ChangeNotifier {
  final Api api;

  List<TaskProject> taskprojects = [];
  List<TaskGroup> taskgroups = [];
  TaskProject? currentProject;
  List<Tag>? currentTags;

  late User user;

  Counter counter = Counter(pomodoroTime: 25, shortBreakTime: 5, longBreakTime: 15);

  GlobalState({required this.api});

  /**
   * for counter
   */
  Timer? timer;
  // this is for pomodoro and todolist
  TaskGroup? currentTaskGroup;
  Task? currentTask;

  void setCounterTaskGroup(TaskGroup taskGroup) {
    currentTaskGroup = taskGroup;
    notifyListeners();
  }

  void setCounterTask(Task? task) {
    currentTask = task;
    notifyListeners();
  }

  void setFocusState(FocusState focusState) {
    counter.setFocusState(focusState);
    timer?.cancel();
    notifyListeners();
  }

  void startCountDown() {
    counter.isfinished = false;
    timer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (counter.isfinished) {
        timer.cancel();

        if (counter.focusState != FocusState.pomodoro && currentTask != null) {
          currentTask?.finishTime += 1;
          final request = UpdateTaskRequest(id: currentTask!.id, finishTime: currentTask!.finishTime + 1);
          await updateTask(request);
        }
      } else {
        counter.countDownOnce();
      }

      notifyListeners();
    });
  }

  void stopCountDown() {
    counter.state = RunningState.paused;
    timer?.cancel();
    notifyListeners();
  }

  void setTimes({
    required int pomodoroTime,
    required int shortBreakTime,
    required int longBreakTime,
    required int longBreakInterval
  }) {
    counter = Counter(pomodoroTime: pomodoroTime, shortBreakTime: shortBreakTime, longBreakTime: longBreakTime, longBreakInterval: longBreakInterval);
    notifyListeners();
  }

  void resetTimes() {
    counter = Counter(pomodoroTime: 25, shortBreakTime: 5, longBreakTime: 15, longBreakInterval: 4);
    notifyListeners();
  }


  /**
   * todolist module
   */
  String todolistImageUrl(int id) => "${api.todolistUrl}/image/download/$id";
  Future<String> get todolistDefaultImageUrl async {
    final imageitem = await defaultTodoListImage();
    final id = imageitem.id;
    return "${api.todolistUrl}/image/download/$id";
  }

  Future<ImageItem> defaultTodoListImage() async {
    return await api.defaultTodoListImage();
  }

  Future<void> setCurrentTaskProject(TaskProject taskproject) async {
    currentProject = taskproject;

    currentTags = await api.findAllTags(taskproject.id);
    taskgroups = await api.findAllTaskGroups(taskproject.id);
  }

  void setCurrentTaskGroupAt(int index) {
    currentTaskGroup = taskgroups[index];
  }

  Future<void> login(String username, String password) async {
    final user = await api.login(username, password);
    this.user = user;
  }

  Future<ImageItem> uploadImage(MultipartFile file) async {
    return await api.uploadImage(file);
  }


  Future<void> insertTask(PostTaskRequest request) async {
    Task task = await api.insertTask(request);
    TaskGroup taskgroup = taskgroups.where((element) => element.id == request.parentid).first;
    taskgroup.tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> deleteTask(int id, int taskgroupIndex) async {
    await api.deleteTask(id);
    TaskGroup taskgroup = taskgroups[taskgroupIndex];
    taskgroup.tasks.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> updateTask(UpdateTaskRequest request) async {
    /// please modify task in parent code, you can think this `updateTask` as commit
    await api.updateTask(request);
    notifyListeners();
  }

  Future<void> removeDeadline(int id) async {
    await api.removeDeadline(id);
  }

  Future<void> removeNotifyTime(int id) async {
    await api.removeNotifyTime(id);
  }

  Future<void> removeTag(int tagid, Task task) async {
    // edit task in parent code block first
    await api.removeTag(task.id, tagid);
    notifyListeners();
  }

  Future<void> insertSubTask(PostSubTaskRequest request, Task task) async {
    final subtask = await api.insertSubTask(request);
    task.subtasks?.insert(0, subtask);
    notifyListeners();
  }

  Future<void> deleteSubTask(int id, Task task) async {
    await api.deleteSubTask(id);
    task.subtasks?.removeWhere((element) => element.id == id);

    notifyListeners();
  }

  Future<void> updateSubTask(UpdateSubTaskRequest request, Task task) async {
    final subtask = await api.updateSubTask(request);
    final index = task.subtasks?.indexWhere((element) => element.id == subtask.id);

    if (request.reorderAt == null) {
      if (index != null && index != -1) {
        task.subtasks![index] = subtask;
      }

      notifyListeners();
    } else {
      if (index != null && index != -1) {
        task.subtasks?.removeAt(index);
        task.subtasks?.insert(request.reorderAt! - 1, subtask);
      }
    }
  }

  Future<void> loadTaskProjects() async {
    taskprojects = await api.findAllTaskProjects();
    notifyListeners();
  }

  Future<void> loadTaskGroups(int projectid) async {
    taskgroups = await api.findAllTaskGroups(projectid);
    notifyListeners();
  }

 Future<void> insertTaskProject(PostTaskProjectRequest request) async {
    TaskProject taskproject = await api.insertTaskProject(request);
    taskprojects.insert(0, taskproject);
    notifyListeners();
 }

 Future<void> deleteTaskProject(int id) async {
    await api.deleteTaskProject(id);
    taskprojects.removeWhere((element) => element.id == id);
    notifyListeners();
 }

 Future<void> updateTaskProject(UpdateTaskProjectRequest request) async {
   TaskProject taskproject = await api.updateTaskProject(request);
   currentProject = taskproject;
   final index = taskprojects.indexWhere((element) => element.id == taskproject.id);
   taskprojects[index] = taskproject;

   notifyListeners();
 }

 void changeAvatarId(int id) {
   currentProject?.avatarid = id;
   notifyListeners();
 }

 Future<void> insertTaskGroup(PostTaskGroupRequest request) async {
    TaskGroup taskgroup = await api.insertTaskGroup(request);
    taskgroups.add(taskgroup);
    notifyListeners();
 }

 Future<void> insertTaskGroupAfter(PostTaskGroupRequest request, int indexStartFrom0) async {
    TaskGroup taskgroup = await api.insertTaskGroupAfter(request, indexStartFrom0 + 1);
    taskgroups.insert(0, taskgroup);
    final otherRequest = UpdateTaskGroupRequest(id: taskgroup.id, reorderAt: indexStartFrom0 + 2);
    await api.updateTaskGroup(otherRequest);

    final item = taskgroups.removeAt(0);
    taskgroups.insert(indexStartFrom0 + 1, item);

    notifyListeners();
 }

 Future<void> deleteTaskGroup(int id) async {
    await api.deleteTaskGroup(id);
    taskgroups.removeWhere((element) => element.id == id);
    notifyListeners();
 }

 Future<void> reorderTaskGroup(TaskGroup taskgroup, int oldindex, int newindex) async {
   final request = UpdateTaskGroupRequest(id: taskgroup.id, reorderAt: newindex);
   await api.updateTaskGroup(request);

   final item = taskgroups.removeAt(oldindex);
   taskgroups.insert(newindex - 1, item);

 }

 Future<void> updateTaskGroup(UpdateTaskGroupRequest request, int index) async {
    TaskGroup taskgroup = await api.updateTaskGroup(request);

    if (request.reorderAt != null) {

    } else {
      taskgroups[index] = taskgroup;
      notifyListeners();
    }
 }

  Future<void> insertTagNotExists(PostTagRequest request, Task task) async {
    final tag = await api.insertTag(request);

    final index = currentTags?.indexWhere((element) => element.id == tag.id);

    if (index == null || index == -1) {
      final request1 = PostTaskTagRequest(taskid: task.id, tagid: tag.id);
      await api.insertTaskTag(request1);
      task.tags?.add(tag);
      currentTags?.add(tag);
      notifyListeners();
    }
  }

  Future<void> insertTagExists(Tag tag, Task task) async {
    final request = PostTaskTagRequest(taskid: task.id, tagid: tag.id);
    await api.insertTaskTag(request);
    task.tags?.add(tag);

    notifyListeners();
  }

  Future<void> updateTag(UpdateTagRequest request, Task task) async {
    final tag = await api.updateTag(request);
    int? index0 = currentTags?.indexWhere((element) => element.id == tag.id);
    if (index0 != null && index0 != -1) {
      currentTags![index0] = tag;

      int? index1 = task.tags?.indexWhere((element) => element.id == tag.id);

      if (index1 != null && index1 != -1) {
        task.tags![index1] = tag;
      }

      notifyListeners();
    }
  }

}