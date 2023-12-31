import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/model/login.dart';
import 'package:frontend/request/login.dart';
import 'package:path/path.dart';
import 'package:web_socket_channel/io.dart';

class UserApi {
  static const String contentType = "application/json; charset=utf-8";
  static const ResponseType responseType = ResponseType.json;
  static BaseOptions defaultOptions = BaseOptions(contentType: contentType, responseType: responseType);

  String jwttoken = "";
  late final Dio instance;
  User? user;
  String? username;

  final String loginUrl;
  final String userUrl;
  final String defaultRoleUrl;

  Future<void> Function(DioException) errorHandler;
  Map<String, String> get headers => {
    "Authorization": jwttoken.startsWith("Bearer") ? jwttoken : "Bearer $jwttoken"
  };

  UserApi({
    required this.loginUrl,
    required this.userUrl,
    required this.defaultRoleUrl,
    required this.errorHandler
  }): assert(!loginUrl.endsWith("/")), assert(!userUrl.endsWith("/")) {
    instance = Dio(defaultOptions);
    instance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
  }

  Future<void> authenticate(String name, String password) async {
    String passwordHash = md5.convert(utf8.encode(password)).toString();

    LoginRequest request = LoginRequest(username: name, passwordHash: passwordHash);
    Response<Map<String, dynamic>> response = await instance.post(loginUrl, data: request.toJson());
    Map<String, dynamic> data = response.data!["data"];
    jwttoken = data["jwttoken"];
    // instance.options.headers["Authorization"] = "Bearer $jwttoken";

    response = await instance.get("$userUrl", options: Options(
        headers: headers
    ));

    data = response.data!["data"];

    final result = User.fromJson(data);
    user = result;
  }

  Future<User> login(String name, String password) async {
    username = name;
    // if you use authenticate flatten, the server will return 400 status
    await authenticate(name, password);

    Response<Map<String, dynamic>> response = await instance.get("$userUrl?name=$name", options: Options(
      headers: headers
    ));

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
    // instance.options.headers["Authorization"] = token1;

    try {
      Response<Map<String, dynamic>> response = await instance.get(userUrl, options: Options(
        headers: headers
      ));

      user = User.fromJson(response.data!["data"]);
    } on DioException catch (exception) {
      await errorHandler(exception);
    }

  }
  
  Future<void> register(PostUserRequest request) async {
    final registerUrl = join(userUrl, "register");
    await instance.post(registerUrl, data: request.toJson());
  }

  Future<Role> findDefaultRole() async {
    Response<Map<String, dynamic>> response = await instance.get(defaultRoleUrl, options: Options(
      headers: headers
    ));
    return Role.fromJson(response.data!["data"]);
  }
}

