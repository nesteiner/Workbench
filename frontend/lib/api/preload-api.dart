import 'package:dio/dio.dart';
import 'package:frontend/constants.dart';

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
      logger.e("error in check connection", error: exception.error, stackTrace: exception.stackTrace);
      return false;
    }
  }

  Future<bool> checkLogin(String backendUrl, String hostUrl, String username, String password) async {
    late String url;
    if (backendUrl.endsWith("/")) {
      url = backendUrl.substring(0, backendUrl.length - 1);
    } else {
      url = backendUrl;
    }

    final Response<Map<String, dynamic>> response = await instance.post("$url/samba/check/login", data: {
      "url": hostUrl,
      "username": username,
      "password": password
    });

    return response.data!["data"];
  }
}