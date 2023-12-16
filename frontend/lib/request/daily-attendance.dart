import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/utils.dart';

class PostDailyAttendanceTaskRequest {
  String name;
  Icon icon;
  String encouragement;
  Frequency frequency;
  Goal goal;
  KeepDays keepdays;
  Group group;
  DateTime startTime;
  List<NotifyTime> notifyTimes;
  int userid;

  PostDailyAttendanceTaskRequest({
    required this.name,
    required this.icon,
    required this.encouragement,
    required this.frequency,
    required this.goal,
    required this.keepdays,
    required this.group,
    required this.startTime,
    required this.notifyTimes,
    required this.userid
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name.trim(),
      "icon": icon.toJson(),
      "encouragement": encouragement.trim(),
      "frequency": frequency.toJson(),
      "goal": goal.toJson(),
      "keepdays": keepdays.toJson(),
      "group": group.stringValue(),
      "startTime": formatDateTime(startTime),
      "notifyTimes": notifyTimes.map((e) => e.toJson()).toList(),
      "userid": userid
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

  factory UpdateDailyAttendanceTaskRequest.fromObject(Task task) {
    return UpdateDailyAttendanceTaskRequest(
      id: task.id,
      name: task.name.trim(),
      icon: task.icon,
      encouragement: task.encouragement.trim(),
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