import 'package:dio/dio.dart';

class CustomInterceptors extends Interceptor {
  void Function(DioException) errorHandler;

  CustomInterceptors({required this.errorHandler});
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    errorHandler(err);
    super.onError(err, handler);
  }
}