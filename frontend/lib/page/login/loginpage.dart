import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/page/homepage.dart';
import 'package:frontend/state.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  late GlobalState state;
  final usernameController = TextEditingController(text: "steiner");
  final passwordController = TextEditingController(text: "password");

  @override
  Widget build(BuildContext context) {
    state = context.read<GlobalState>();
    return Scaffold(
      body: Center(child: buildBody(context)),
    );
  }

  Widget buildBody(BuildContext context) {
    final column = Column(
      children: [
        SizedBox(height: settings["page.login.body.margin-top"],),
        const Icon(Icons.login, size: 50,),
        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "用户名",
              hintText: "输入用户名"
            ),
          ),
        ),

        Padding(
          padding: settings["page.login.body.padding"],
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "密码",
              hintText: "输入密码"
            ),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(settings["page.login.button.height"])
          ),
          onPressed: () async {
            if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {

              try {
                await state.login(usernameController.text, passwordController.text);
                // navigator.push(MaterialPageRoute(builder: (_) => HomePage()));
                navigatorKey.currentState?.pushNamed("/taskproject");
              } on DioException catch (exception) {
                print(exception);
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    content: Text(exception.message ?? "fuck"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          navigatorKey.currentState?.pop();
                        },
                        
                        child: const Text("确定"),
                      )
                    ],
                  )
                );

              }
            }
          },
          
          child: const Text("Login", style: TextStyle(color: Colors.white),),
        )
      ],
    );

    return FractionallySizedBox(
      widthFactor: 0.5,
      child: column,
    );
  }
}