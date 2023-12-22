import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/request/clipboard.dart';
import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ClipboardWidget extends StatefulWidget {
  ClipboardWidgetState createState() => ClipboardWidgetState();
}

class ClipboardWidgetState extends State<ClipboardWidget> {
  final scrollController = ScrollController();
  final textController = TextEditingController();

  ClipboardState? _state;
  ClipboardState get state => _state!;
  set state(ClipboardState value) => _state ??= value;
  UserState? _loginState;
  UserState get loginState => _loginState!;
  set loginState(UserState value) => _loginState ??= value;

  ClipboardWriter? clipboardWriter;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        state.findAll();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    state = context.read<ClipboardState>();
    loginState = context.read<UserState>();

    return Container(
      decoration: settings["widget.home.clipboard.decoration"],
      padding: settings["widget.home.clipboard.padding"],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: buildListView(context)),
          buildTextField(context)
        ],
      ),
    );
  }
  
  Widget buildListView(BuildContext context) {
    return SizedBox(
      height: settings["widget.home.clipboard.height"],

      child: FutureBuilder(
        future: state.findAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e("error in clipboard state findAll", error: snapshot.error, stackTrace: snapshot.stackTrace);
            return Center(child: Text(snapshot.error.toString()),);
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(),);
          }

          return Selector<ClipboardState, int>(
            selector: (_, state) => state.data.length,
            builder: (context, value, child) => ListView.builder(
                controller: scrollController,
                itemCount: value,
                itemBuilder: (context, index) => ListTile(
                  title: Text(state.data[index].text, style: settings["widget.home.clipboard.listview.text-style"],),
                  subtitle: Text(state.data[index].id.toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          clipboardWriter ??= ClipboardWriter.instance;
                          final item = DataWriterItem();
                          item.add(Formats.plainText(state.data[index].text));
                          await clipboardWriter?.write([item]);
                        },

                        icon: const Icon(Icons.copy),
                      ),

                      IconButton(
                        onPressed: () async {
                          await state.deleteOne(state.data[index].id);
                        },

                        icon: const Icon(Icons.delete, color: Colors.red,),
                      ),
                    ],
                  ),
                )
            ),
          );
        },
      ),
    );
  }
  
  Widget buildTextField(BuildContext context) {
    final disabledNotifier = ValueNotifier(textController.text.isEmpty);

    final textfield = TextField(
      controller: textController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "输入文字",
      ),

      minLines: 1,
      maxLines: 3,
      onChanged: (value) {
        disabledNotifier.value = value.isEmpty;
      },
    );


    final button = ValueListenableBuilder(
        valueListenable: disabledNotifier,
        builder: (context, value, child) => ElevatedButton(
            onPressed: value ? null : () async {
              final request = PostTextRequest(text: textController.text, userid: loginState.userid);
              await state.insertOne(request);
              textController.text = "";
            },

            child: const Text("提交")
        )
    );

    return Row(
      children: [
        Expanded(
          child: textfield,
        ),

        SizedBox(width: settings["common.unit.size"],),
        button
      ],
    );
  }
}