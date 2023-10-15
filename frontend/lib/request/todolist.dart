import 'package:flutter/material.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/utils.dart';

class PostTagRequest {
  String name;
  int parentid;
  Color color;

  PostTagRequest({required this.name, required this.parentid, required this.color});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "parentid": parentid,
      "color": color.toHex()
    };
  }
}

class PostTaskTagRequest {
  int taskid;
  int tagid;

  PostTaskTagRequest({required this.taskid, required this.tagid});

  Map<String, dynamic> toJson() {
    return {
      "taskid": taskid,
      "tagid": tagid
    };
  }
}

class PostSubTaskRequest {
  int parentid;
  String name;

  PostSubTaskRequest({required this.parentid, required this.name});

  Map<String, dynamic> toJson() {
    return {
      "parentid": parentid,
      "name": name
    };
  }
}

class PostTaskGroupRequest {
  int parentid;
  String name;

  PostTaskGroupRequest({required this.parentid, required this.name});

  Map<String, dynamic> toJson() {
    return {
      "parentid": parentid,
      "name": name
    };
  }
}

class PostTaskProjectRequest {
  int userid;
  String name;
  int? avatarid;
  String? profile;

  PostTaskProjectRequest({required this.userid, required this.name, this.avatarid, this.profile});

  Map<String, dynamic> toJson() {
    return {
      "userid": userid,
      "name": name,
      "avatarid": avatarid,
      "profile": profile
    };
  }
}

class PostTaskRequest {
  String name;
  int parentid;
  String? note;
  int priority;
  List<Tag>? tags;
  String? deadline;
  String? notifyTime;
  int expectTime;

  PostTaskRequest({
    required this.name,
    required this.parentid,
    required this.priority,
    required this.expectTime,
    this.note,
    this.tags,
    this.deadline,
    this.notifyTime
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "parentid": parentid,
      "note": note,
      "priority": priority,
      "tags": tags?.map((e) => {"id": e.id, "name": e.name}).toList(),
      "deadline": deadline,
      "notifyTime": notifyTime,
      "expectTime": expectTime
    };
  }
}

class UpdateSubTaskRequest {
  int id;
  String? name;
  bool? isdone;
  int? reorderAt;

  UpdateSubTaskRequest({required this.id, this.name, this.isdone, this.reorderAt});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "reorderAt": reorderAt,
      "isdone": isdone
    };
  }
}

class UpdateTagRequest {
  int id;
  String name;

  UpdateTagRequest({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name
    };
  }
}

class UpdateTaskGroupRequest {
  int id;
  String? name;
  int? reorderAt;

  UpdateTaskGroupRequest({required this.id, this.name, this.reorderAt});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "reorderAt": reorderAt
    };
  }
}

class UpdateTaskProjectRequest {
  int id;
  String? name;
  int? avatarid;
  String? profile;

  UpdateTaskProjectRequest({required this.id, this.name, this.avatarid, this.profile});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "avatarid": avatarid,
      "profile": profile
    };
  }
}

class UpdateTaskRequest {
  int id;
  String? name;
  int? reorderAt;
  bool? isdone;
  String? deadline;
  String? notifyTime;
  String? note;
  int? priority;
  int? expectTime;
  int? finishTime;
  int? parentid;

  UpdateTaskRequest({
    required this.id,
    this.name,
    this.reorderAt,
    this.isdone,
    this.deadline,
    this.notifyTime,
    this.note,
    this.priority,
    this.expectTime,
    this.finishTime,
    this.parentid
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "reorderAt": reorderAt,
      "isdone": isdone,
      "deadline": deadline,
      "notifyTime": notifyTime,
      "note": note,
      "priority": priority,
      "expectTime": expectTime,
      "finishTime": finishTime,
      "parentid": parentid
    };
  }
}