import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:path_provider/path_provider.dart';

class ImageUploader extends StatefulWidget {
  Image image;
  final void Function(String) onTap;
  
  ImageUploader({required this.image, required this.onTap});

  @override
  ImageUploaderState createState() => ImageUploaderState();
}

class ImageUploaderState extends State<ImageUploader> {
  final controller = CropController();

  @override
  Widget build(BuildContext context) {
    Uint8List imagebyte = Uint8List(0);
    
    return GestureDetector(
      onTap: () async {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null) {
          final imagefile = File(result.files.single.path!);
          final imagedata = await imagefile.readAsBytes();
          final crop = FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.8,
            child: Crop(
              image: imagedata,
              controller: controller,
              onCropped: (image) async {
                imagebyte = image;

                final tempDirectory = await getTemporaryDirectory();
                final path = "${tempDirectory.path}/tempimage";
                final file = File(path);
                if (file.existsSync()) {
                  await file.delete();
                }

                await file.create();
                await file.writeAsBytes(imagebyte);

                setState(() {
                  widget.image = Image.file(File(path), fit: BoxFit.cover, alignment: Alignment.topCenter,);
                });

              },

              interactive: true,
              fixArea: true,
              aspectRatio: 2,
            ),
          );

          final actions = [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white
              ),

              onPressed: () {
                navigatorKey.currentState?.pop();
              },

              child: const Text("取消", style: TextStyle(color: Colors.blue),),
            ),

            SizedBox(
              width: settings["widget.image-uploader.buttons.margin"],
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue
              ),

              onPressed: () async {
                controller.crop();
                navigatorKey.currentState?.pop();
              },

              child: const Text("确定", style: TextStyle(color: Colors.white),),
            )
          ];


          final content = Column(
            children: [
              Expanded(child: crop),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              )
            ],
          );

          if (!context.mounted) {
            return;
          }

          showDialog(
              context: context,

              builder: (context) => Center(child: content)
          );



          widget.onTap(result.files.single.path!);
        }
      },

      child: Container(
        width: settings["widget.image-uploader.width"],
        height: settings["widget.image-uploader.height"],
        decoration: BoxDecoration(
          borderRadius: settings["widget.image-uploader.border-radius"]
        ),

        child: widget.image,
      ),
    );
  }
}



