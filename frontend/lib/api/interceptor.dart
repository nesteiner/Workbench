import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class CustomInterceptors extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      navigatorKey.currentState?.popUntil(ModalRoute.withName("/login"));
    }

    super.onError(err, handler);
  }
}