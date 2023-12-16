import 'package:flutter/cupertino.dart';
import 'package:frontend/model/samba.dart';
import 'package:frontend/utils.dart';

class FileManagerController {
  (String, SortBy) state = ("/", SortBy.name);
  final shouldRebuild = ValueNotifier(0);
  final titleNotifier = ValueNotifier("/");

  String get currentPath => path;
  String get path => state.$1;
  SortBy get sort => state.$2;

  int index = 0;

  set path(String value) {
    state = (value, sort);
    shouldRebuild.value += 1;
  }

  set sort(SortBy sortBy) {
    state = (path, sortBy);
    shouldRebuild.value += 1;
  }

  void updatePath(String path) {
    this.path = path;
    titleNotifier.value = basename(path);
  }

  void update() {
    shouldRebuild.value += 1;
  }

  bool isRoot() {
    return index == 0;
  }

  void gotoParent() {
    if (!isRoot()) {
      openDirectory(parentOf(path), true);
    }
  }

  void openDirectory(String path, bool toParent) {
    updatePath(path);

    if (!toParent) {
      index += 1;
    } else {
      index -= 1;
    }
  }
}