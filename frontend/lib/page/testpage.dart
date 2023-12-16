import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  final String text;
  TestPage({required this.text});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  int count = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.text),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.text, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),),
            Text(count.toString(), style: const TextStyle(fontSize: 38),)
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            count += 1;
          });
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}