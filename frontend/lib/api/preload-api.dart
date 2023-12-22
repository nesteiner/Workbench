import 'package:dio/dio.dart';
import 'package:frontend/constants.dart';
import 'package:path/path.dart';

class PreloadApi {
  final instance = Dio(BaseOptions(responseType: ResponseType.json));

  Future<bool> checkConnection(String url) async {
    try {
      late String url1;
      if (url.endsWith("/")) {
        url1 = url.substring(0, url.length - 1);
      } else {
        url1 = url;
      }

      await instance.get("$url1/check");
      return true;
    } on DioException catch (exception) {
      logger.e("error in check connection", error: exception.error,
          stackTrace: exception.stackTrace);
      return false;
    }
  }

  Future<bool> checkLogin(String backendUrl, String hostUrl, String username,
      String password) async {
    final url = join(backendUrl, "samba/check/login");

    try {
      final Response<Map<String, dynamic>> response = await instance.post(
          url, data: {
        "url": hostUrl,
        "username": username,
        "password": password
      });

      return response.data!["data"];
    } on DioException catch (exception, stackTrace) {
      logger.e("error in check login samba", error: exception.error,
          stackTrace: stackTrace);
      return false;
    }
  }
}