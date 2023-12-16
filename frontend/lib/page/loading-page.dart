import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(),),
    );
  }
}