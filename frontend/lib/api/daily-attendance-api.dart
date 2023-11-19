import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/model/daily-attendance.dart';
import 'package:frontend/request/daily-attendance.dart';

class DailyAttendanceApi extends Api {
  static const String contentType = "application/json; charset=utf-8";
  static const ResponseType responseType = ResponseType.json;
  static BaseOptions defaultOptions = BaseOptions(contentType: contentType, responseType: responseType);

  late final Dio instance;

  String dailyAttendanceUrl;

  DailyAttendanceApi({required this.dailyAttendanceUrl}): assert(!dailyAttendanceUrl.endsWith("/")) {
    instance = Dio(defaultOptions);
    instance.interceptors.add(CustomInterceptors());
  }

  void setToken(String token) {
    instance.options.headers["Authorization"] = "Bearer $token";
  }

  Future<DailyAttendanceTask> insertOne(PostDailyAttendanceTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post(dailyAttendanceUrl, data: request.toJson());
    return DailyAttendanceTask.fromJson(response.data!["data"]);
  }

  Future<DailyAttendanceTask> updateOne(UpdateDailyAttendanceTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put(dailyAttendanceUrl, data: request.toJson());
    final result = DailyAttendanceTask.fromJson(response.data!["data"]);

    return result;
  }

  Future<void> updateArchive(UpdateArchiveTaskRequest request) async {
    await instance.put("$dailyAttendanceUrl/archive", data: request.toJson());
  }

  Future<DailyAttendanceTask> updateProgress(UpdateProgressRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$dailyAttendanceUrl/progress", data: request.toJson());
    return DailyAttendanceTask.fromJson(response.data!["data"]);
  }

  Future<void> deleteOne(int id) async {
    await instance.delete("$dailyAttendanceUrl/$id");
  }

  Future<DailyAttendanceTask> findOne(int id) async {
    Response<Map<String, dynamic>> response = await instance.post("$dailyAttendanceUrl/$id");
    return DailyAttendanceTask.fromJson(response.data!["data"]);
  }

  Future<Map<String, List<DailyAttendanceTask>>> findAllOfLatest7Days() async {
    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/current-7");
    final data = response.data!["data"] as Map<String, List<dynamic>>;

    return data.map((key, value0) {
      final List<DailyAttendanceTask> value = value0.map((e) => DailyAttendanceTask.fromJson(e)).toList();
      return MapEntry(key, value);
    });
  }

  Future<List<DailyAttendanceTask>> findAllOfCurrentDay() async {
    Response<Map<String, dynamic>> response = await instance.get("$dailyAttendanceUrl/current-day");
    final data = response.data!["data"];

    return data.map<DailyAttendanceTask>((e) => DailyAttendanceTask.fromJson(e)).toList();
  }

  Future<void> resetToday(int id) async {
    await instance.put("$dailyAttendanceUrl/$id");
  }

  Future<ImageItem> uploadImage(MultipartFile file) async {
    FormData data = FormData.fromMap({
      "file": file
    });

    Response<Map<String, dynamic>> response = await instance.post("$dailyAttendanceUrl/icon/upload", data: data);
    return ImageItem.fromJson(response.data!["data"]);
  }
}