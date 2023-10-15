import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';

const int LOW_PRIORITY = 0;
const int NORMAL_PRIORITY = 1;
const int HIGH_PRIORITY = 2;

class Tag {
  int id;
  String name;
  int parentid;
  Color color;

  Tag({required this.id, required this.name, required this.parentid, required this.color});

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other.runtimeType != Tag) {
      return false;
    }

    Tag otherTag = other as Tag;
    return id == otherTag.id;
  }

  static Tag fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["id"],
      name: json["name"],
      parentid: json["parentid"],
      // TODO transform string to Color, like red, blue, #000000 -> Color
      color: HexColor.fromHex(json["color"])
    );
  }
}

class TaskProject {
  int id;
  int index;
  String name;
  int avatarid;
  int userid;
  String? profile;
  DateTime createTime;
  DateTime updateTime;

  TaskProject({
    required this.id,
    required this.index,
    required this.name,
    required this.avatarid,
    required this.userid,
    this.profile,
    required this.createTime,
    required this.updateTime
  });

  static TaskProject fromJson(Map<String, dynamic> json) {
    return TaskProject(
        id: json["id"],
        index: json["index"],
        name: json["name"],
        avatarid: json["avatarid"],
        userid: json["userid"],
        profile: json["profile"],
        createTime: parseIntoDateTime(json["createTime"]),
        updateTime: parseIntoDateTime(json["updateTime"])
    );
  }
}

class TaskGroup {
  int id;
  int index;
  String name;
  List<Task> tasks;
  DateTime createTime;
  DateTime updateTime;
  int parentid;
  
  TaskGroup({
    required this.id,
    required this.index,
    required this.name,
    required this.tasks,
    required this.createTime,
    required this.updateTime,
    required this.parentid
  });

  static TaskGroup fromJson(Map<String, dynamic> json) {
    return TaskGroup(
        id: json["id"],
        index: json["index"],
        name: json["name"],
        tasks: json["tasks"].map<Task>((e) => Task.fromJson(e)).toList(),
        createTime: parseIntoDateTime(json["createTime"]),
        updateTime: parseIntoDateTime(json["updateTime"]),
        parentid: json["parentid"]
    );
  }
}

class Task {
  int id;
  String name;
  int index;
  bool isdone;
  int priority;
  String? note;
  DateTime createTime;
  DateTime updateTime;
  List<SubTask>? subtasks;
  DateTime? deadline;
  DateTime? notifyTime;
  List<Tag>? tags;
  int parentid;
  int expectTime;
  int finishTime;

  Task({
    required this.id,
    required this.name,
    required this.index,
    required this.isdone,
    required this.priority,
    required this.createTime,
    required this.updateTime,
    required this.parentid,
    required this.expectTime,
    required this.finishTime,
    this.note,
    this.subtasks,
    this.deadline,
    this.notifyTime,
    this.tags,
  });

  static Task fromJson(Map<String, dynamic> json) {
    DateTime? deadline = null;
    DateTime? notifyTime = null;

    if (json["deadline"] != null) {
      deadline = parseIntoDateTime(json["deadline"]);
    }

    if (json["notifyTime"] != null) {
      notifyTime = parseIntoDateTime(json["notifyTime"]);
    }

    return Task(
      id: json["id"],
      name: json["name"],
      index: json["index"],
      isdone: json["isdone"],
      priority: json["priority"],
      note: json["note"],
      createTime: parseIntoDateTime(json["createTime"]),
      updateTime: parseIntoDateTime(json["updateTime"]),
      subtasks: json["subtasks"].map<SubTask>((e) => SubTask.fromJson(e)).toList(),
      deadline: deadline,
      notifyTime: notifyTime,
      // json["tags"] is not null always
      tags: json["tags"].map<Tag>((e) => Tag.fromJson(e)).toList(),
      parentid: json["parentid"],

      expectTime: json["expectTime"],
      finishTime: json["finishTime"]
    );
  }
}

class SubTask {
  int id;
  int index;
  String name;
  bool isdone;
  int parentid;

  SubTask({
    required this.id,
    required this.index,
    required this.name,
    required this.isdone,
    required this.parentid
  });

  static SubTask fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json["id"],
      index: json["index"],
      name: json["name"],
      isdone: json["isdone"],
      parentid: json["parentid"]
    );
  }
}

class ImageItem {
  int id;
  String name;

  ImageItem({required this.id, required this.name});

  static ImageItem fromJson(Map<String, dynamic> json) {
    return ImageItem(
      id: json["id"],
      name: json["name"]
    );
  }
}