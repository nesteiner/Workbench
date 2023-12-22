import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/samba.dart';

class SambaApi extends Api {
  late final Dio instance;
  late final Dio bytesInstance;

  final String sambaUrl;
  final String sambaHostUrl;
  Future<void> Function(DioException) errorHandler;

  SambaApi({required this.sambaUrl, required this.sambaHostUrl, required this.errorHandler}): assert(!sambaUrl.endsWith("/")) {
    final baseOptions0 = BaseOptions(baseUrl: sambaUrl, responseType: ResponseType.json);
    instance = Dio(baseOptions0);

    final baseOptions1 = BaseOptions(baseUrl: sambaUrl, responseType: ResponseType.bytes);
    bytesInstance = Dio(baseOptions1);

    instance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
    bytesInstance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
  }

  @override
  void setToken(String token) {
    late String token1;
    if (token.startsWith("Bearer")) {
      token1 = token;
    } else {
      token1 = "Bearer $token";
    }

    instance.options.headers["Authorization"] = token1;
    bytesInstance.options.headers["Authorization"] = token1;
  }

  Future<bool> login(String name, String password) async {
    try {
      await instance.post(sambaUrl, data: {
        "url": sambaHostUrl,
        "username": name,
        "password": password
      });

      return true;
    } on DioException catch (exception) {
      logger.e(exception.stackTrace);
      return false;
    }
  }

  Future<List<SambaFile>> findFiles(String path) async {
    final Response<Map<String, dynamic>> response = await instance.get("?path=$path");
    final list = (response.data!["data"] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map(SambaFile.fromJson).toList();
  }

  Future<void> download(String path, String target) async {
    final targetFile = File(target);

    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    await targetFile.create();

    final response = await bytesInstance.get<Uint8List>("/download", queryParameters: {
      "path": path
    });

    final bytes = response.data!;

    await targetFile.writeAsBytes(bytes);
  }

  /// @params path: 上传路径
  /// @params filepath: 文件路径
  Future<void> upload(String path, String filepath) async {
    final formData = FormData.fromMap({
      "path": path,
      "file": await MultipartFile.fromFile(filepath)
    });

    await instance.post("/upload", data: formData);
  }

  Future<void> createDirectory(String path) async {
    await instance.post(sambaUrl, queryParameters: {
      "path": path
    });
  }
  
  Future<void> deleteFile(String path) async {
    await instance.delete(sambaUrl, queryParameters: {
      "path": path
    });
  }
}