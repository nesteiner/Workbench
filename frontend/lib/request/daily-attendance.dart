import 'package:flutter/material.dart' show Color;
import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/utils.dart';

class PostDailyAttendanceTaskRequest {
  final String name;
  final Icon icon;
  final String encouragement;
  final Frequency frequency;
  final Goal goal;
  final KeepDays keepdays;
  final Group group;
  final List<NotifyTime> notifyTimes;
  final int userid;

  PostDailyAttendanceTaskRequest({
    required this.name,
    required this.icon,
    required this.encouragement,
    required this.frequency,
    required this.goal,
    required this.keepdays,
    required this.group,
    required this.notifyTimes,
    required this.userid
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "icon": icon.toJson(),
      "encouragement": encouragement,
      "frequency": frequency.toJson(),
      "goal": goal.toJson(),
      "keepdays": keepdays.toString(),
      "group": group.stringValue(),
      "notifyTimes": notifyTimes.map((e) => e.toJson()).toList(),
      "userid": userid
    };
  }
}

class PostIconWordRequest {
  final int word;
  late final String color;

  PostIconWordRequest({
    required this.word,
    required Color color
  }) {
    this.color = color.toHex();
  }

  Map<String, dynamic> toJson() {
    return {
      "word": word,
      "color": color
    };
  }
}

class UpdateProgressRequest {
  final int id;
  final Progress progress;

  UpdateProgressRequest({
    required this.id,
    required this.progress
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "progress": progress.toJson()
    };
  }
}

class UpdateDailyAttendanceTaskRequest {
  final int id;
  final String name;
  final Icon icon;
  final String encouragement;
  final Frequency frequency;
  final Goal goal;
  // this need to translate
  final DateTime startTime;
  final KeepDays keepdays;
  final Group group;
  final List<NotifyTime> notifyTimes;

  UpdateDailyAttendanceTaskRequest({
    required this.id,
    required this.name,
    required this.icon,
    required this.encouragement,
    required this.frequency,
    required this.goal,
    required this.startTime,
    required this.keepdays,
    required this.group,
    required this.notifyTimes
  });

  factory UpdateDailyAttendanceTaskRequest.fromObject(DailyAttendanceTask task) {
    return UpdateDailyAttendanceTaskRequest(
      id: task.id,
      name: task.name,
      icon: task.icon,
      encouragement: task.encouragement,
      frequency: task.frequency,
      goal: task.goal,
      startTime: task.startTime,
      keepdays: task.keepdays,
      group: task.group,
      notifyTimes: task.notifyTimes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "icon": icon.toJson(),
      "encouragement": encouragement,
      "frequency": frequency.toJson(),
      "startTime": formatDateTime(startTime),
      "goal": goal.toJson(),
      "keepdays": keepdays.toJson(),
      "group": group.stringValue(),
      "notifyTimes": notifyTimes.map((e) => e.toJson()).toList()
    };
  }
}

class UpdateArchiveTaskRequest {
  final int id;
  final bool isarchive;

  UpdateArchiveTaskRequest({
    required this.id,
    required this.isarchive
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "isarchive": isarchive
    };
  }
}