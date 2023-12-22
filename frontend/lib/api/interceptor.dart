import 'package:dio/dio.dart';

class CustomInterceptors extends Interceptor {
  Future<void> Function(DioException) errorHandler;

  CustomInterceptors({required this.errorHandler});
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    await errorHandler(err);
    super.onError(err, handler);
  }
}