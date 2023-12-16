import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/model/login.dart';
import 'package:frontend/request/login.dart';

class LoginApi {
  static const String contentType = "application/json; charset=utf-8";
  static const ResponseType responseType = ResponseType.json;
  static BaseOptions defaultOptions = BaseOptions(contentType: contentType, responseType: responseType);

  String jwttoken = "";
  late final Dio instance;
  User? user;
  String? username;

  String loginUrl;
  String userUrl;


  void Function(DioException) errorHandler;

  LoginApi({required this.loginUrl, required this.userUrl, required this.errorHandler}): assert(!loginUrl.endsWith("/")), assert(!userUrl.endsWith("/")) {
    instance = Dio(defaultOptions);
    instance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
  }

  Future<void> authenticate(String name, String password) async {
    String passwordHash = md5.convert(utf8.encode(password)).toString();

    LoginRequest request = LoginRequest(username: name, passwordHash: passwordHash);
    Response<Map<String, dynamic>> response = await instance.post(loginUrl, data: request.toJson());
    Map<String, dynamic> data = response.data!["data"];
    jwttoken = data["jwttoken"];
    instance.options.headers["Authorization"] = "Bearer $jwttoken";
  }

  Future<User> login(String name, String password) async {
    username = name;
    // if you use authenticate flatten, the server will return 400 status
    await authenticate(name, password);

    Response<Map<String, dynamic>> response = await instance.get("$userUrl?name=$name");
    Map<String, dynamic> data = response.data!["data"];

    final result = User.fromJson(data);
    user = result;
    return result;
  }

  void passToken(Api api) {
    api.setToken(jwttoken);
  }

  Future<void> setToken(String token) async {
    late String token1;
    if (token.startsWith("Bearer")) {
      token1 = token;
    } else {
      token1 = "Bearer $token";
    }

    jwttoken = token1;
    instance.options.headers["Authorization"] = token1;

    Response<Map<String, dynamic>> response = await instance.get("$userUrl");
    Map<String, dynamic> data = response.data!["data"];

    final result = User.fromJson(data);
    user = result;
  }


}

