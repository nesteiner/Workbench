import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/extension/samba-file-extension.dart';
import 'package:frontend/model/samba.dart';
import 'package:frontend/utils.dart';
import 'package:path/path.dart';
import 'package:frontend/model/samba.dart' as sm;
import 'package:frontend/page/error-page.dart';
import 'package:frontend/page/loading-page.dart';
import 'package:frontend/page/samba/file-manager.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/utils.dart' as utils;
import 'package:provider/provider.dart';


class SambaPage extends StatefulWidget {
  @override
  State<SambaPage> createState() => _SambaPageState();
}

class _SambaPageState extends State<SambaPage> {
  GlobalState? _globalState;
  GlobalState get globalState => _globalState!;
  set globalState(GlobalState value) => _globalState ??= value;

  SambaState? _state;
  SambaState get state => _state!;
  set state(SambaState value) => _state ??= value;

  List<SambaFile> files = [];

  utils.SetStateCallback? _setStateFiles;
  utils.SetStateCallback get setStateFiles => _setStateFiles!;
  set setStateFiles(utils.SetStateCallback value) => _setStateFiles ??= value;

  final errorTextNotifier = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    globalState = context.read<GlobalState>();
    state = globalState.sambaState!;

    return FutureBuilder(
        future: state.login(globalState.sambaUser!, globalState.sambaPassword!),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorPage(error: snapshot.error, stackTrace: snapshot.stackTrace,);
          }

          if (!snapshot.hasData) {
            return const LoadingPage();
          }

          if (!snapshot.requireData) {
            return ErrorPage(error: "Login Failed", stackTrace: snapshot.stackTrace,);
          }

          return Scaffold(
            appBar: buildAppBar(context),
            resizeToAvoidBottomInset: false,
            body: ControlBackButton(
              controller: state.controller,
              child: FileManager(
                  controller: state.controller,
                  api: state.api,
                  builder: (context, snapshot) {
                    files = snapshot;
                    return StatefulBuilder(
                      builder: (_, setState) {
                        setStateFiles = setState;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            return buildListItem(context, index);
                          },
                        );
                      }
                    );
                  }
              ),
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  final path = result.files.single.path;
                  await state.upload(state.controller.path, path!);
                }
              },

              child: const Icon(Icons.add),
            ),
          );
        }
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: ValueListenableBuilder<String>(
        valueListenable: state.controller.titleNotifier,
        builder: (context, title, _) => Text(title),
      ),

      leading: IconButton(
        onPressed: () {
          state.controller.gotoParent();
        },

        icon: const Icon(Icons.arrow_back),
      ),

      actions: [
        IconButton(
          onPressed: () {
            // TODO create folder
            final controller = TextEditingController();
            final disabledNotifier = ValueNotifier(true);
            showDialog(context: context, useRootNavigator: false, builder: (_) => AlertDialog(
              title: const Text("创建新文件夹"),
              content: ValueListenableBuilder(
                valueListenable: errorTextNotifier,
                builder: (_, value, child) => TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "文件夹名",
                    hintText: "输入文件夹名",
                    errorText: value.isEmpty ? null : value
                  ),

                  onChanged: (value) {
                    disabledNotifier.value = files.any((element) => element.name == value) && controller.text.isEmpty && controller.text.contains(" ");
                    if (controller.text.isEmpty) {
                      errorTextNotifier.value = "文件夹名不能为空";
                    } else if (controller.text.contains(" ")) {
                      errorTextNotifier.value = "文件夹名不能有空格";
                    } else {
                      errorTextNotifier.value = "";
                    }
                  },
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    sambaNavigatorKey.currentState?.pop();
                  },

                  child: const Text("取消"),
                ),

                ValueListenableBuilder(
                    valueListenable: disabledNotifier,
                    builder: (_, value, child) => TextButton(
                      onPressed: value ? null : () async {
                        final path = join(state.controller.path, controller.text);
                        logger.i("path is $path");
                        await state.createDirectory(path);

                        sambaNavigatorKey.currentState?.pop();
                      },

                      child: const Text("确定"),
                    )
                )
              ],
            ));
          },

          icon: const Icon(Icons.create_new_folder_outlined),
        ),

        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              onTap: () {
                setStateFiles(() {
                  files = files.sortByName;
                });
              },

              child: const Text("按名称排序")
            ),

            PopupMenuItem(
              onTap: () {
                setStateFiles(() {
                  files = files.sortByDate;
                });
              },

              child: const Text("按日期排序")
            ),

            PopupMenuItem(
              onTap: () {
                setStateFiles(() {
                  files = files.sortBySize;
                });
              },

              child: const Text("按大小排序"),
            ),

            PopupMenuItem(
              onTap: () {
                setStateFiles(() {
                  files = files.sortByType;
                });

              },

              child: const Text("按类型排序"),
            )
          ],

          child: const Icon(Icons.sort_rounded),
        )
      ],
    );
  }

  Widget buildListItem(BuildContext context, int index) {
    final entity = files[index];
    return Slidable(
      key: ValueKey("${entity.path}-${entity.name}"),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showDialog(context: context, useRootNavigator: false, builder: (_) => AlertDialog(
                title: const Text("确定删除吗"),
                content: const Text("这个操作无法恢复"),
                actions: [
                  TextButton(
                    onPressed: () {
                      sambaNavigatorKey.currentState?.pop();
                    },

                    child: const Text("取消"),
                  ),

                  TextButton(
                    onPressed: () async {
                      await state.deleteFile(entity.path);
                      sambaNavigatorKey.currentState?.pop();
                    },

                    child: const Text("确定"),
                  )
                ],
              ));
            },

            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: "Delete",
          )
        ],
      ),

      child: Card(
        child: ListTile(
          leading: leadingIcon(context, entity.filetype),
          title: Text(utils.basename(entity.path),
            style: const TextStyle(color: Colors.black),),
          subtitle: buildSubTitle(context, entity),
          trailing: trailingButtons(context, entity),

          onTap: () async {
            if (entity.filetype == sm.FileType.directory) {
              state.controller.openDirectory(entity.path, false);
            }
          },
        ),
      ),
    );
  }

  Widget buildSubTitle(BuildContext context, sm.SambaFile sambaFile) {
    if (sambaFile.filetype == sm.FileType.directory) {
      return Text("${sambaFile.lastModified}".substring(0, 10));
    } else {
      return Text(utils.formatBytes(sambaFile.size!));
    }
  }

  Widget leadingIcon(BuildContext context, sm.FileType filetype) {
    if (filetype == sm.FileType.directory) {
      return const Icon(Icons.folder);
    } else if (filetype == sm.FileType.text) {
      return const Icon(Icons.feed_outlined);
    } else if (filetype == sm.FileType.image) {
      return const Icon(Icons.image);
    } else if (filetype == sm.FileType.video) {
      return const Icon(Icons.video_camera_back_outlined);
    } else if (filetype == sm.FileType.audio) {
      return const Icon(Icons.audiotrack);
    } else {
      return const Icon(Icons.file_open);
    }
  }

  Widget? trailingButtons(BuildContext context, sm.SambaFile entity) {
    if (entity.filetype == sm.FileType.directory) {
      return null;
    }

    final button = IconButton(
        onPressed: () async {
          late String? result;
          if (isDesktop) {
            result = await FilePicker.platform.saveFile(fileName: "temp");
          } else {

            final flag = await showDialog<bool?>(context: context, useRootNavigator: false, builder: (_) => AlertDialog(
              title: const Text("保存文件"),
              content: const Text("文件将会被保存到Download目录中"),
              actions: [
                TextButton(
                  onPressed: () {
                    sambaNavigatorKey.currentState?.pop(null);
                  },

                  child: const Text("取消"),
                ),

                TextButton(
                  onPressed: () {
                    sambaNavigatorKey.currentState?.pop(true);
                  },

                  child: const Text("确定"),
                )
              ],
            )) ?? false;

            if (flag) {
              result = join("/storage/emulated/0/Download", entity.name);
              logger.i("result is $result");
            }
          }


          if (result != null) {
            final path = result;
            await state.download(entity.path, path);
          }
        },

        icon: const Icon(Icons.download)
    );

    return button;
  }
}