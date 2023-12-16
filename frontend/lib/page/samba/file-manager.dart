import 'package:flutter/material.dart';
import 'package:frontend/api/samba-api.dart';
import 'package:frontend/controller/file-manager-controller.dart';
import 'package:frontend/extension/samba-file-extension.dart';
import 'package:frontend/model/samba.dart';

typedef Builder = Widget Function(
    BuildContext context,
    List<SambaFile> snapshot
    );

typedef ErrorBuilder = Widget Function(
    BuildContext context,
    Object? error
    );

class FileManager extends StatelessWidget {
  final Widget? loadingScreen;
  final Widget? emptyFolder;
  final ErrorBuilder? errorBuilder;
  final FileManagerController controller;
  final Builder builder;
  final SambaApi api;

  FileManager({
    this.emptyFolder,
    this.loadingScreen,
    this.errorBuilder,
    required this.controller,
    required this.api,
    required this.builder
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller.shouldRebuild,
        builder: (context, value, child) => FutureBuilder<List<SambaFile>>(
            future: entityList(controller.state.$1, controller.state.$2),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return buildErrorPapge(context, snapshot.error);
              }

              if (!snapshot.hasData) {
                return buildLoadingScreen(context);
              }

              final entities = snapshot.requireData;

              if (entities.isEmpty) {
                return buildEmptyDirectory(context);
              } else {
                return builder(
                  context,
                  entities
                );
              }
            }
        )
    );
  }

  Widget buildErrorPapge(BuildContext context, Object? error) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error);
    }

    return Container(
      color: Colors.red,
      child: Center(
        child: Text("Error $error", style: const TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget buildLoadingScreen(BuildContext context) {
    if (loadingScreen == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(
        child: loadingScreen,
      );
    }
  }


  Widget buildEmptyDirectory(BuildContext context) {
    if (emptyFolder == null) {
      return const Center(
        child: Text("Empty Directory"),
      );
    } else {
      return emptyFolder!;
    }
  }

  Future<List<SambaFile>> entityList(String path, SortBy sortBy) async {
    final entities = await api.findFiles(path);
    entities.removeWhere((element) => element.name == "IPC\$/");

    switch (sortBy) {
      case SortBy.name:
        return entities.sortByName;
      case SortBy.size:
        return entities.sortBySize;
      case SortBy.date:
        return entities.sortByDate;
      case SortBy.type:
        return entities.sortByType;
    }
  }

}

class ControlBackButton extends StatelessWidget {
  final Widget child;
  final FileManagerController controller;

  const ControlBackButton({
    required this.child,
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        onWillPop: () async {
          return !controller.isRoot();
        },
        child: child
    );
  }
}