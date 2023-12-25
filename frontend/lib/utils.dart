import 'package:flutter/material.dart';
import "dart:math" as math;
import "dart:io";

import "package:frontend/page/root-page.dart";

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

const List<String> suffix = ["B", "KB", "MG", "GB", "TB"];
const List<int> powbase = [
  1,
  1024,
  1048576,
  1073741824,
  1099511627776
];

String formatBytes(int bytes, [int precision = 2]) {
  final base = (bytes == 0) ? 0 : (math.log(bytes) / math.log(1024)).floor();
  final size = bytes / powbase[base];
  final formattedSize = size.toStringAsFixed(precision);
  return "$formattedSize ${suffix[base]}";
}

String parentOf(String path) {
  int rootEnd = -1;
  if (Platform.isWindows) {
    if (path.startsWith(RegExp(r'^(?:\\\\|[a-zA-Z]:[/\\])'))) {
      // Root ends at first / or \ after the first two characters.
      rootEnd = path.indexOf(new RegExp(r'[/\\]'), 2);
      if (rootEnd == -1) return path;
    } else if (path.startsWith('\\') || path.startsWith('/')) {
      rootEnd = 0;
    }
  } else if (path.startsWith('/')) {
    rootEnd = 0;
  }
  // Ignore trailing slashes.
  // All non-trivial cases have separators between two non-separators.
  int pos = path.lastIndexOf(Platform.isWindows
      ? RegExp(r'[^/\\][/\\]+[^/\\]')
      : RegExp(r'[^/]/+[^/]'));
  if (pos > rootEnd) {
    return path.substring(0, pos + 1);
  } else if (rootEnd > -1) {
    return path.substring(0, rootEnd + 1);
  } else {
    return path;
  }
}

String basename(String path) {
  final segments = path.split("/");

  if (path.endsWith("/")) {
    return segments[segments.length - 2];
  } else {
    return segments.last;
  }
}

typedef SetStateCallback = void Function(void Function());

bool? _isDesktop;
bool get isDesktop {
  _isDesktop ??= Platform.isWindows || Platform.isLinux;
  return _isDesktop!;
}