import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';

void main() {
  final colors = [
    Colors.red.withOpacity(0.3).toHex(),
    Colors.blue.withOpacity(0.3).toHex(),
    Colors.green.withOpacity(0.3).toHex()
  ];

  colors.forEach(print);

}