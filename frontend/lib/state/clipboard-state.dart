import 'package:flutter/material.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/clipboard-api.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/clipboard.dart';
import 'package:frontend/request/clipboard.dart';

class ClipboardState extends ChangeNotifier implements Api{
  final ClipboardApi api;
  final int size;
  int page = 0;

  final List<ClipboardText> data = [];

  ClipboardState({required this.api, required this.size});

  // FIXME
  Future<bool> findAll() async {
    final result = await api.findAll(page, size);

    if (data.lastOrNull?.id != result.lastOrNull?.id) {
      final mod = data.length % size;
      data.addAll(result);

      if (mod == 0) {
        page = (data.length / size).floor();
      } else {
        page = (data.length / size).floor() + 1;
      }

      notifyListeners();
    }

    return true;
  }

  @override
  void setToken(String token) {
    api.setToken(token);
  }

  Future<void> insertOne(PostTextRequest request) async {
    final text = await api.insertOne(request);
    data.add(text);

    final mod = data.length % size;
    if (mod == 0) {
      page = (data.length / size).floor();
    } else {
      page = (data.length / size).floor() + 1;
    }

    notifyListeners();
  }

  Future<void> deleteOne(int id) async {
    await api.deleteOne(id);
    data.removeWhere((element) => element.id == id);

    final mod = data.length % size;
    if (mod == 0) {
      page = (data.length / size).floor();
    } else {
      page = (data.length / size).floor() + 1;
    }

    notifyListeners();
  }
}