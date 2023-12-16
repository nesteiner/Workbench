import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/controller/file-manager-controller.dart';
import 'package:frontend/model/samba.dart' as sm;
import 'package:frontend/page/error-page.dart';
import 'package:frontend/page/loading-page.dart';
import 'package:frontend/page/samba/file-manager.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/utils.dart';
import 'package:provider/provider.dart';

class SambaPage extends StatelessWidget {
  late final GlobalState globalState;
  late final SambaState state;

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
            body: ControlBackButton(
              controller: state.controller,
              child: FileManager(
                  controller: state.controller,
                  api: state.api,
                  builder: (context, snapshot) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: snapshot.length,
                    itemBuilder: (context, index) {
                      final entity = snapshot[index];
                      return Card(
                        child: ListTile(
                          leading: leadingIcon(context, entity.filetype),
                          title: Text(basename(entity.path), style: const TextStyle(color: Colors.black),),
                          subtitle: buildSubTitle(context, entity),
                          trailing: trailingButtons(context, entity),

                          onTap: () async {
                            if (entity.filetype == sm.FileType.directory) {
                              state.controller.openDirectory(entity.path, false);
                            }
                          },
                        ),
                      );
                    },
                  )
              ),
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
          },

          icon: const Icon(Icons.create_new_folder_outlined),
        ),

        IconButton(
          onPressed: () {
            // TODO sort
          },

          icon: const Icon(Icons.sort_rounded),
        ),

        IconButton(
          onPressed: () {
            // TODO select storage
          },

          icon: const Icon(Icons.sd_storage_rounded),
        )
      ],
    );
  }

  Widget buildSubTitle(BuildContext context, sm.SambaFile sambaFile) {
    if (sambaFile.filetype == sm.FileType.directory) {
      return Text("${sambaFile.lastModified}".substring(0, 10));
    } else {
      return Text(formatBytes(sambaFile.size!));
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
          final result = await FilePicker.platform.saveFile(fileName: "temp");
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