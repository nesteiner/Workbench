import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';

/// @Serializable
/// sealed class Frequency {
///     @Serializable
///     @SerialName("Days")
///     // 按天
///     class Days(val weekdays: Array<DayOfWeek>): Frequency()
///     @Serializable
///     @SerialName("CountInWeek")
///     // 按周，每天几周
///     class CountInWeek(val count: Int): Frequency()
///     @Serializable
///     @SerialName("Interval")
///     // 按时间间隔
///     class Interval(val count: Int): Frequency()
/// }
abstract class Frequency {
   static Frequency fromJson(Map<String, dynamic> json) {
    if (json["type"] == "Days") {
      return FrequencyDays.fromJson(json);
    } else if (json["type"] == "CountInWeek") {
      return FrequencyCountInWeek.fromJson(json);
    } else if (json["type"] == "Interval") {
      return FrequencyInterval.fromJson(json);
    } else {
      throw Exception("no such frequency type");
    }
  }

  Map<String, dynamic> toJson();
}

class FrequencyDays extends Frequency {
  final List<String> weekdays;

  FrequencyDays({required this.weekdays});

  factory FrequencyDays.fromJson(Map<String, dynamic> json) {
    return FrequencyDays(weekdays: json["weekdays"].cast<String>());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Days",
      "weekdays": weekdays
    };
  }
}

class FrequencyCountInWeek extends Frequency {
  final int count;

  FrequencyCountInWeek({required this.count});

  factory FrequencyCountInWeek.fromJson(Map<String, dynamic> json) {
    return FrequencyCountInWeek(count: json["count"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "CountInWeek",
      "count": count
    };
  }
}

class FrequencyInterval extends Frequency {
  final int count;

  FrequencyInterval({required this.count});

  factory FrequencyInterval.fromJson(Map<String, dynamic> json) {
    return FrequencyInterval(count: json["count"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Interval",
      "count": count
    };
  }
}


/// @Serializable
/// sealed class Goal {
///     @Serializable
///     @SerialName("CurrentDay")
///     object CurrentDay: Goal()
///     @Serializable
///     @SerialName("Amount")
///     class Amount(val total: Int, val unit: String, val eachAmount: Int): Goal()
/// }
abstract class Goal {
  static Goal fromJson(Map<String, dynamic> json) {
    if (json["type"] == "CurrentDay") {
      return GoalCurrentDay.fromJson(json);
    } else if (json["type"] == "Amount") {
      return GoalAmount.fromJson(json);
    } else {
      throw Exception("no such goal type");
    }
  }

  Map<String, dynamic> toJson();
}

class GoalCurrentDay extends Goal {
  GoalCurrentDay();

  factory GoalCurrentDay.fromJson(Map<String, dynamic> _json) {
    return GoalCurrentDay();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "CurrentDay"
    };
  }
}

class GoalAmount extends Goal {
  int total;
  String unit;
  int eachAmount;

  GoalAmount({required this.total, required this.unit, required this.eachAmount});

  factory GoalAmount.fromJson(Map<String, dynamic> json) {
    return GoalAmount(total: json["total"], unit: json["unit"], eachAmount: json["eachAmount"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Amount",
      "total": total,
      "unit": unit,
      "eachAmount": eachAmount
    };
  }
}

enum Group {
  noon,
  afternoon,
  night,
  other
}

extension ToStringExtension on Group {
  String stringValue() {
    if (this == Group.noon) {
      return "Noon";
    } else if (this == Group.afternoon) {
      return "Afternoon";
    } else if (this == Group.night) {
      return "Night";
    } else {
      return "Other";
    }
  }

  String stringValue2() {
    switch (this) {
      case Group.noon:
        return "上午";

      case Group.afternoon:
        return "下午";

      case Group.night:
        return "晚上";

      case Group.other:
        return "其他";
    }
  }
}
///@Serializable
/// sealed class Icon {
///     @Serializable
///     @SerialName("Asset")
///     class Image(val entryId: Int, val backgroundId: Int, val backgroundColor: String): Icon()
///
///     @Serializable
///     @SerialName("Word")
///     // color is hex
///     class Word(val char: Char, val color: String): Icon()
/// }

abstract class Icon {
  static Icon fromJson(Map<String, dynamic> json) {
    if (json["type"] == "Image") {
      return IconImage.fromJson(json);
    } else if (json["type"] == "Word") {
      return IconWord.fromJson(json);
    } else {
      throw Exception("no such icon type");
    }
  }

  Map<String, dynamic> toJson();
}

class IconImage extends Icon {
  int entryId;
  int backgroundId;
  Color backgroundColor;

  IconImage({required this.entryId, required this.backgroundId, required this.backgroundColor});

  factory IconImage.fromJson(Map<String, dynamic> json) {
    return IconImage(entryId: json["entryId"], backgroundId: json["backgroundId"], backgroundColor: HexColor.fromHex(json["backgroundColor"]));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Image",
      "entryId": entryId,
      "backgroundId": backgroundId,
      "backgroundColor": backgroundColor.toHex()
    };
  }
}

class IconWord extends Icon {
  String word;
  Color color;

  IconWord({required this.word, required this.color});

  factory IconWord.fromJson(Map<String, dynamic> json) {
    return IconWord(
      word: json["char"],
      color: HexColor.fromHex(json["color"])
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Word",
      "char": word,
      "color": color.toHex()
    };
  }
}


/// @Serializable
/// sealed class KeepDays {
///     @Serializable
///     @SerialName("Forever")
///     object Forever: KeepDays()
///     @Serializable
///     @SerialName("Manual")
///     class Manual(val days: Int): KeepDays()
/// }

abstract class KeepDays {
  static KeepDays fromJson(Map<String, dynamic> json) {
    if (json["type"] == "Forever") {
      return KeepDaysForever.fromJson(json);
    } else if (json["type"] == "Manual") {
      return KeepDaysManual.fromJson(json);
    } else {
      throw Exception("no such keepdays type");
    }
  }

  Map<String, dynamic> toJson();

  KeepDays copy();
}

class KeepDaysForever extends KeepDays {
  KeepDaysForever();

  factory KeepDaysForever.fromJson(Map<String, dynamic> _json) {
    return KeepDaysForever();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Forever"
    };
  }

  @override
  KeepDaysForever copy() {
    // TODO: implement copy
    return KeepDaysForever();
  }

  @override
  bool operator ==(Object other) {
    return other is KeepDaysForever;
  }
}

class KeepDaysManual extends KeepDays {
  final int days;

  KeepDaysManual({required this.days});

  factory KeepDaysManual.fromJson(Map<String, dynamic> json) {
    return KeepDaysManual(days: json["days"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Manual",
      "days": days
    };
  }

  @override
  KeepDaysManual copy() {
    return KeepDaysManual(days: days);
  }

  @override
  bool operator ==(Object other) {
    if (other is! KeepDaysManual) {
      return false;
    }

    final object = other as KeepDaysManual;
    return days == object.days;
  }
}

/// @Serializable
/// class NotifyTime(val hour: Int, val minute: Int)

class NotifyTime {
  final int hour;
  final int minute;

  NotifyTime({required this.hour, required this.minute});

  factory NotifyTime.fromJson(Map<String, dynamic> json) {
    return NotifyTime(hour: json["hour"], minute: json["minute"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "hour": hour,
      "minute": minute
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return "${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}";
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is! NotifyTime) {
      return false;
    }

    final otherTime = other as NotifyTime;
    return hour == otherTime.hour && minute == otherTime.minute;
  }
}


/// @Serializable
/// sealed class Progress {
///     @Serializable
///     @SerialName("NotScheduled")
///     object NotScheduled: Progress()
///
///     @Serializable
///     @SerialName("Ready")
///     object Ready: Progress()
///
///     @Serializable
///     @SerialName("Done")
///     object Done: Progress()
///
///     @Serializable
///     @SerialName("Doing")
///     class Doing(val total: Int, val unit: String, val amount: Int): Progress()
/// }
abstract class Progress {
  static Progress fromJson(Map<String, dynamic> json) {
    if (json["type"] == "NotScheduled") {
      return ProgressNotScheduled.fromJson(json);
    } else if (json["type"] == "Ready") {
      return ProgressReady.fromJson(json);
    } else if (json["type"] == "Done") {
      return ProgressDone.fromJson(json);
    } else if (json["type"] == "Doing") {
      return ProgressDoing.fromJson(json);
    } else {
      throw Exception("no such progress type");
    }
  }

  Map<String, dynamic> toJson();
}

class ProgressNotScheduled extends Progress {
  ProgressNotScheduled();

  factory ProgressNotScheduled.fromJson(Map<String, dynamic> _json) {
    return ProgressNotScheduled();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "NotScheduled"
    };
  }
}

class ProgressReady extends Progress {
  ProgressReady();

  factory ProgressReady.fromJson(Map<String, dynamic> _json) {
    return ProgressReady();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Ready"
    };
  }
}

class ProgressDone extends Progress {
  ProgressDone();

  factory ProgressDone.fromJson(Map<String, dynamic> _json) {
    return ProgressDone();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "Done"
    };
  }
}

class ProgressDoing extends Progress {
  final int total;
  final String unit;
  final int amount;

  ProgressDoing({required this.total, required this.unit, required this.amount});

  factory ProgressDoing.fromJson(Map<String, dynamic> json) {
    return ProgressDoing(
      total: json["total"],
      unit: json["unit"],
      amount: json["amount"]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    return {
      "type": "Doing",
      "total": total,
      "unit": unit,
      "amount": amount
    };
  }
}

class DailyAttendanceTask {
  final int id;
  String name;
  Icon icon;
  String encouragement;
  Frequency frequency;
  Goal goal;
  DateTime startTime;
  KeepDays keepdays;
  Group group;
  List<NotifyTime> notifyTimes;
  Progress progress;
  bool isarchived;
  final int persistenceDays;
  final int consecutiveDays;

  DailyAttendanceTask({
    required this.id,
    required this.name,
    required this.icon,
    required this.encouragement,
    required this.frequency,
    required this.goal,
    required this.startTime,
    required this.keepdays,
    required this.group,
    required this.notifyTimes,
    required this.progress,
    required this.isarchived,
    required this.persistenceDays,
    required this.consecutiveDays
  });

  factory DailyAttendanceTask.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceTask(
        id: json["id"],
        name: json["name"],
        icon: Icon.fromJson(json["icon"]),
        encouragement: json["encouragement"],
        frequency: Frequency.fromJson(json["frequency"]),
        goal: Goal.fromJson(json["goal"]),
        startTime: parseIntoDateTime(json["startTime"]),
        keepdays: KeepDays.fromJson(json["keepdays"]),
        group: groupFromString(json["group"]),
        notifyTimes: json["notifyTimes"].map<NotifyTime>((e) => NotifyTime.fromJson(e)).toList(),
        progress: Progress.fromJson(json["progress"]),
        isarchived: json["isarchived"],
        persistenceDays: json["persistenceDays"],
        consecutiveDays: json["consecutiveDays"]
    );
  }

  static Group groupFromString(String value) {
    if (value == "Noon") {
      return Group.noon;
    } else if (value == "Afternoon") {
      return Group.afternoon;
    } else if (value == "Night") {
      return Group.night;
    } else {
      return Group.other;
    }
  }

  DailyAttendanceTask copy() {
    return DailyAttendanceTask(
        id: id,
        name: name,
        icon: icon,
        encouragement: encouragement,
        frequency: frequency,
        goal: goal,
        startTime: startTime,
        keepdays: keepdays,
        group: group,
        notifyTimes: notifyTimes,
        progress: progress,
        isarchived: isarchived,
        persistenceDays: persistenceDays,
        consecutiveDays: consecutiveDays
    );
  }

  String toString() {
    return "${id}"
        "-${name}"
        "-${icon.toJson()}"
        "-$encouragement"
        "-${frequency.toJson()}"
        "-${goal.toJson()}"
        "-$startTime"
        "-${keepdays.toJson()}"
        "-${group}"
        "-${notifyTimes.map((e) => e.toJson()).toList()}"
        "-${progress.toJson()}"
        "-$isarchived"
        "-$persistenceDays"
        "-$consecutiveDays";
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
