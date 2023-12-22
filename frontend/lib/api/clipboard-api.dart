import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/model/clipboard.dart';
import 'package:frontend/request/clipboard.dart';

class ClipboardApi extends Api {
  late final Dio instance;

  final String clipboardUrl;
  Future<void> Function(DioException) errorHandler;

  ClipboardApi({required this.clipboardUrl, required this.errorHandler}): assert(!clipboardUrl.endsWith("/")) {
    final baseOptions0 = BaseOptions(baseUrl: clipboardUrl, responseType: ResponseType.json);
    instance = Dio(baseOptions0);

    instance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
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
  }


  Future<List<ClipboardText>> findAll(int page, int size) async {
    final Response<Map<String, dynamic>> response = await instance.get(clipboardUrl, queryParameters: {
      "page": page,
      "size": size
    });

    final Map<String, dynamic> data = response.data!["data"];
    final List<dynamic> content = data["content"]!;

    return content.map<ClipboardText>((e) => ClipboardText.fromJson(e)).toList();
  }

  Future<ClipboardText> insertOne(PostTextRequest request) async {
    final Response<Map<String, dynamic>> response = await instance.post(clipboardUrl, data: request.toJson());
    final Map<String, dynamic> data = response.data!["data"];
    return ClipboardText.fromJson(data);
  }

  Future<void> deleteOne(int id) async {
    await instance.delete("$clipboardUrl/$id");
  }
}