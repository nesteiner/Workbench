import 'package:flutter/material.dart';

String zeroPadding(int number) {
  if (number < 10) {
    return "0$number";
  } else {
    return number.toString();
  }
}

String formatDateTime(DateTime dateTime) => "${dateTime.year}-${zeroPadding(dateTime.month)}-${zeroPadding(dateTime.day)} ${zeroPadding(dateTime.hour)}:${zeroPadding(dateTime.minute)}";
DateTime parseIntoDateTime(String dateTimeString) => DateTime.parse(dateTimeString);


class PageContainer<T> {
  List<T> content;
  int totalPages;

  PageContainer({required this.content, required this.totalPages});
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}