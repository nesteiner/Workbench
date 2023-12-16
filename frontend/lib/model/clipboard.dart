import 'package:frontend/utils.dart';

class ClipboardText {
  final int id;
  final String text;
  final DateTime createTime;

  ClipboardText({required this.id, required this.text, required this.createTime});

  factory ClipboardText.fromJson(Map<String, dynamic> json) {
    return ClipboardText(id: json["id"], text: json["text"], createTime: parseIntoDateTime(json["createTime"]));
  }
}