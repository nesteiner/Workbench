import 'package:flutter/material.dart';

class SwitcherController extends ChangeNotifier {
  bool? _value;

  bool get value => _value!;
  set value(bool value1) {
    _value = value1;
    notifyListeners();
  }

  SwitcherController({required bool value}) {
    this.value = value;
  }
}