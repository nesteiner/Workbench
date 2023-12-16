import 'package:flutter/material.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/controller/file-manager-controller.dart';

class SambaState extends ChangeNotifier implements Api {
  final SambaApi api;
  final FileManagerController controller;

  SambaState({required this.api, required this.controller});

  @override
  void setToken(String token) {
    api.setToken(token);
  }

  Future<bool> login(String name, String password) async {
    return await api.login(name, password);
  }

  void findFiles() {
    controller.update();
  }

  Future<void> download(String path, String target) async {
    await api.download(path, target);
  }

  Future<void> upload(String path, String filepath) async {
    await api.upload(path, filepath);
    controller.update();
  }

  Future<void> createDirectory(String path) async {
    await api.createDirectory(path);
    controller.update();
  }

  Future<void> deleteFile(String path) async {
    await api.deleteFile(path);
    controller.update();
  }
}