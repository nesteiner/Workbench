import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/request/login.dart';
import 'package:frontend/state/user-state.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget with StateMixin {
  static final emailPattern = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final Map<String, TextEditingController> controllers = {
    "username": TextEditingController(),
    "password": TextEditingController(),
    "email": TextEditingController(),
  };

  String get username => controllers["username"]!.text;
  String get password => controllers["password"]!.text;
  String get email => controllers["email"]!.text;

  bool get enabled => username.isNotEmpty && password.isNotEmpty && emailPattern.hasMatch(email);
  final disabledNotifier = ValueNotifier(true);
  bool get disabled => !enabled;

  @override
  Widget build(BuildContext context) {
    userState = context.read<UserState>();

    return Scaffold(
      appBar: AppBar(title: const Text("注册"), ),
      body: Center(child: buildBody(context),),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget buildBody(BuildContext context) {
    final column = Column(
      children: [

        SizedBox(height: settings["page.login.body.margin-top"],),
        Image.asset("assets/register.png"),
        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: controllers["username"],
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "用户名",
                hintText: "输入用户名"
            ),

            onChanged: (value) {
              disabledNotifier.value = disabled;
            },
          ),
        ),

        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: controllers["password"],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "密码",
              hintText: "输入密码",
            ),

            onChanged: (value) {
              disabledNotifier.value = disabled;
            },
          ),
        ),

        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: controllers["email"],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "邮箱",
              hintText: "输入邮箱",
            ),

            onChanged: (value) {
              disabledNotifier.value = disabled;
            },
          ),
        ),


        ValueListenableBuilder(
          valueListenable: disabledNotifier,
          builder: (context, value, child) =>
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(settings["page.login.button.height"])
                ),

                onPressed: value ? null : () async {
                  try {
                    await userState.register(
                      username: controllers["username"]!.text,
                      password: controllers["password"]!.text,
                      email: controllers["email"]!.text
                    );
                  } on DioException catch (excecption, stackTrace) {
                    if (!context.mounted) {
                      return;
                    }

                    logger.e("error in register", error: excecption.error, stackTrace: stackTrace);
                    showDialog(context: context, builder: (_) => AlertDialog(
                      title: const Text("注册失败"),
                      content: Text(excecption.response?.data["message"] ?? "Fuck"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text("确定"),
                        )
                      ],
                    ));
                  }
                },

                child: const Text("注册", style: TextStyle(color: Colors.white),),
              ),
        ),

        const Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Icon(Icons.arrow_downward, color: Color.fromRGBO(0, 0, 0, 0.3), size: 30,),
          ),
        )
      ],
    );

    return FractionallySizedBox(
      widthFactor: 0.9,
      child: column,
    );
  }
}