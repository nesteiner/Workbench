class TransferData {
  final String fromuid;
  final String touid;
  final TransferMessage message;

  TransferData({required this.fromuid, required this.touid, required this.message});

  static TransferData fromJson(Map<String, dynamic> json) {
    return TransferData(fromuid: json["fromuid"], touid: json["touid"], message: TransferMessage.fromJson(json["message"]));
  }
}

abstract class TransferMessage {
  static TransferMessage fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "Notification":
        final operation = Operation.fromJson(json["operation"]);
        return Notification(operation: operation);

      case "Error":
        return Error(message: json["message"]);

      default:
        throw Exception("unknown type: ${json["type"]}");
    }
  }
}

class Notification extends TransferMessage {
  final Operation operation;

  Notification({required this.operation});
}

class Error extends TransferMessage {
  final String message;

  Error({required this.message});
}

abstract class Operation {
  static Operation fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "TaskProject:Post":
        return TaskProjectPost();
      case "TaskProject:Delete":
        final id = json["id"];
        return TaskProjectDelete(id: id);
      case "TaskProject:Update":
        final id = json["id"];
        return TaskProjectUpdate(id: id);
      case "TaskGroup:Post":
        final taskprojectId = json["taskprojectId"];
        return TaskGroupPost(taskprojectId: taskprojectId);

      case "TaskGroup:Delete":
        final taskprojectId = json["taskprojectId"];
        final id = json["id"];

        return TaskGroupDelete(taskprojectId: taskprojectId, id: id);

      case "TaskGroup:Update":
        final taskprojectId = json["taskprojectId"];
        final id = json["id"];

        return TaskGroupUpdate(taskprojectId: taskprojectId, id: id);

      case "Task:Post":
        final taskprojectId = json["taskprojectId"];
        final taskgroupId = json["taskgroupId"];

        return TaskPost(taskprojectId: taskprojectId, taskgroupId: taskgroupId, id: json["id"]);

      case "Task:Delete":
        final taskprojectId = json["taskprojectId"];
        final taskgroupId = json["taskgroupId"];
        final id = json["id"];

        return TaskDelete(taskprojectId: taskprojectId, taskgroupId: taskgroupId, id: id);

      case "Task:Update":
        final taskprojectid = json["taskprojectId"];
        final taskgroupId = json["taskgroupId"];
        final id = json["id"];

        return TaskUpdate(taskprojectid: taskprojectid, taskgroupId: taskgroupId, id: id);

      case "DailyAttendance:Post":
        return DailyAttendancePost();

      case "DailyAttendance:Delete":
        final id = json["id"];
        return DailyAttendanceDelete(id: id);

      case "DailyAttendance:Update":
        final id = json["id"];
        return DailyAttendanceUpdate(id: id);

      case "DailyAttendance:Archive":
        final id = json["id"];
        final archive = json["archive"];
        return DailyAttendanceArchive(id: id, archive: archive);

      case "Clipboard:Post":
        return ClipboardPost();

      case "Clipboard:Delete":
        final id = json["id"];
        return ClipboardDelete(id: id);

      case "Samba:Update":
        final parentPath = json["parentPath"];
        return SambaUpdate(parentPath: parentPath);

      default:
        throw Exception("unknown type: ${json["type"]}");
    }
  }
}

class TaskProjectPost extends Operation {

}

class TaskProjectDelete extends Operation {
  final int id;

  TaskProjectDelete({required this.id});
}

class TaskProjectUpdate extends Operation {
  final int id;

  TaskProjectUpdate({required this.id});
}

class TaskGroupPost extends Operation {
  final int taskprojectId;

  TaskGroupPost({required this.taskprojectId});
}

class TaskGroupDelete extends Operation {
  final int taskprojectId;
  final int id;

  TaskGroupDelete({required this.taskprojectId, required this.id});
}

class TaskGroupUpdate extends Operation {
  final int taskprojectId;
  final int id;

  TaskGroupUpdate({required this.taskprojectId, required this.id});
}

class TaskPost extends Operation {
  final int taskprojectId;
  final int taskgroupId;
  final int id;
  TaskPost({required this.taskprojectId, required this.taskgroupId, required this.id});
}

class TaskDelete extends Operation {
  final int taskprojectId;
  final int taskgroupId;
  final int id;

  TaskDelete({required this.taskprojectId, required this.taskgroupId, required this.id});
}

class TaskUpdate extends Operation {
  final int taskprojectid;
  final int taskgroupId;
  final int id;

  TaskUpdate({required this.taskprojectid, required this.taskgroupId, required this.id});
}

class DailyAttendancePost extends Operation {

}

class DailyAttendanceDelete extends Operation {
  final int id;

  DailyAttendanceDelete({required this.id});
}

class DailyAttendanceUpdate extends Operation {
  final int id;

  DailyAttendanceUpdate({required this.id});
}

class DailyAttendanceArchive extends Operation {
  final int id;
  final bool archive;

  DailyAttendanceArchive({required this.id, required this.archive});
}

class ClipboardPost extends Operation {

}

class ClipboardDelete extends Operation {
  final int id;

  ClipboardDelete({required this.id});
}

class SambaUpdate extends Operation {
  final String parentPath;

  SambaUpdate({required this.parentPath});
}