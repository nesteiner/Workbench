import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/request/daily-attendance.dart';

class DailyAttendanceApi extends Api {
  static const String contentType = "application/json; charset=utf-8";
  static const ResponseType responseType = ResponseType.json;
  static BaseOptions defaultOptions = BaseOptions(contentType: contentType, responseType: responseType);
  static final Map<int, String> weekdayMap = {
    DateTime.monday: "MONDAY",
    DateTime.tuesday: "TUESDAY",
    DateTime.wednesday: "WEDNESDAY",
    DateTime.thursday: "THURSDAY",
    DateTime.friday: "FRIDAY",
    DateTime.saturday: "SATURDAY",
    DateTime.sunday: "SUNDAY"
  };

  static final weekdayIndex = {
    "MONDAY": 0,
    "TUESDAY": 1,
    "WEDNESDAY": 2,
    "THURSDAY": 3,
    "FRIDAY": 4,
    "SATURDAY": 5,
    "SUNDAY": 6
  };
  
  late final Dio instance;

  String dailyAttendanceUrl;
  void Function(DioException) errorHandler;
  DailyAttendanceApi({required this.dailyAttendanceUrl, required this.errorHandler}): assert(!dailyAttendanceUrl.endsWith("/")) {
    instance = Dio(defaultOptions);
    instance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
  }

  void setToken(String token) {
    late String token1;
    if (token.startsWith("Bearer")) {
      token1 = token;
    } else {
      token1 = "Bearer $token";
    }

    instance.options.headers["Authorization"] = token1;
  }

  Future<da.Task> insertOne(PostDailyAttendanceTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post(dailyAttendanceUrl, data: request.toJson());
    return da.Task.fromJson(response.data!["data"]);
  }

  Future<da.Task> updateOne(UpdateDailyAttendanceTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put(dailyAttendanceUrl, data: request.toJson());
    final result = da.Task.fromJson(response.data!["data"]);

    return result;
  }

  Future<void> updateArchive(UpdateArchiveTaskRequest request) async {
    await instance.put("$dailyAttendanceUrl/archive", data: request.toJson());
  }

  Future<da.Task> updateProgress(UpdateProgressRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$dailyAttendanceUrl/progress", data: request.toJson());
    return da.Task.fromJson(response.data!["data"]);
  }

  Future<void> deleteOne(int id) async {
    await instance.delete("$dailyAttendanceUrl/$id");
  }

  Future<da.Task?> findOne(int id) async {
    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/$id");
    if (response.data!["data"] == null) {
      return null;
    } else {
      return da.Task.fromJson(response.data!["data"]);
    }
  }

  Future<Map<String, List<da.Task>>> findAllOfLatest7Days() async {
    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/current-7");
    final data = response.data!["data"] as Map<String, dynamic>;

    final map = data.map((key, value0) {
      final List<da.Task> value = value0.map<da.Task>((e) => da.Task.fromJson(e)).toList();
      return MapEntry(key, value);
    });

    final dayOfWeekRecord = Map<String, DateTime>();
    final currentDay = DateTime.now();
    final end = currentDay.add(const Duration(days: 1));
    final past6DateTime = currentDay.subtract(const Duration(days: 6));
    DateTime time = past6DateTime;

    while (time.isBefore(end)) {
      dayOfWeekRecord[weekdayMap[time.weekday]!] = time;
      time = time.add(const Duration(days: 1));
    }

    return Map.fromEntries(
      map.entries.toList()..sort((left, right) => dayOfWeekRecord[left.key]!.compareTo(dayOfWeekRecord[right.key]!))
    );
  }

  Future<List<da.Task>> findAllOfCurrentDay() async {
    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/current-day");
    final data = response.data!["data"];

    return data.map<da.Task>((e) => da.Task.fromJson(e)).toList();
  }

  Future<da.Task> resetToday(int id) async {
    Response<Map<String, dynamic>> response = await instance.put("$dailyAttendanceUrl/reset/$id");
    final data = response.data!["data"];

    return da.Task.fromJson(data);
  }

  Future<da.ImageItem> uploadImage(MultipartFile file) async {
    FormData data = FormData.fromMap({
      "file": file
    });

    Response<Map<String, dynamic>> response = await instance.post("$dailyAttendanceUrl/icon/upload", data: data);
    return da.ImageItem.fromJson(response.data!["data"]);
  }

  Future<Map<da.Task, List<da.Progress>>> statisticsWeekly(int offset) async {
    assert(offset <= 0);
    
    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/statistics/week?offset=$offset");
    final Map<String, dynamic> data = response.data!["data"];
    final result = Map<da.Task, List<da.Progress>>();
    
    for (final entry0 in data.entries) {
      final id = int.parse(entry0.key);
      final task = await findOne(id);
      result[task!] = List<da.Progress>.generate(7, (index) => da.ProgressNotScheduled());
      
      for (final entry1 in entry0.value.entries) {
        final dayOfWeek = entry1.key;
        final progress = da.Progress.fromJson(entry1.value);
        final index = weekdayIndex[dayOfWeek]!;
        result[task]![index] = progress;
      }
    }
    
    return result;
  }
  
  Future<Map<da.Task, List<da.Progress>>> statisticsMonthly(int offset) async {
    assert(offset <= 0);
    
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month - offset.abs() + 1, 1).subtract(const Duration(days: 1));
    final numberOfDays = endOfMonth.day;

    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/statistics/month?offset=$offset");
    final Map<String, dynamic> data = response.data!["data"];
    final result = Map<da.Task, List<da.Progress>>();

    for (final entry0 in data.entries) {
      final id = int.parse(entry0.key);
      final task = await findOne(id);
      result[task!] = List<da.Progress>.generate(numberOfDays, (index) => da.ProgressNotScheduled());

      for (final entry1 in entry0.value.entries) {
        final dayOfMonth = int.parse(entry1.key);
        final progress = da.Progress.fromJson(entry1.value);
        final index = dayOfMonth - 1;
        result[task]![index] = progress;
      }
    }

    return result;
  }
}