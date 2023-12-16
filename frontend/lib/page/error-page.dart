import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class ErrorPage extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  ErrorPage({required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    logger.e("error page", error: error, stackTrace: stackTrace);

    return Scaffold(
      body: Center(child: Text(error.toString()),),
    );
  }
}
