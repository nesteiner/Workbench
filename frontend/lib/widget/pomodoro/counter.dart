import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/pomodoro.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:provider/provider.dart';

class CounterWidget extends StatelessWidget {
  late final TodoListState state;
  @override
  Widget build(BuildContext context) {
    state = context.read<TodoListState>();

    return Container(
      width: settings["widget.pomodoro.counter.width.desktop"],
      decoration: settings["widget.pomodoro.counter.decoration"],
      margin: settings["widget.pomodoro.counter.margin"],
      padding: settings["widget.pomodoro.counter.padding"],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildFocusButton(context),
          buildTimeText(context),
          buildClickButton(context)
        ],
      ),

    );
  }

  Widget buildFocusButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextButton(
          onPressed: () {
            state.setFocusState(FocusState.pomodoro);
          },

          child: Text("Pomodoro", style: settings["widget.pomodoro.counter.focus.text-style"],),
        ),

        TextButton(
          onPressed: () {
            state.setFocusState(FocusState.shortBreak);
          },

          child: Text("Short break", style: settings["widget.pomodoro.counter.focus.text-style"],),
        ),

        TextButton(
          onPressed: () {
            state.setFocusState(FocusState.longBreak);
          },

          child: Text("Long break", style: settings["widget.pomodoro.counter.focus.text-style"],),
        )
      ],
    );
  }

  Widget buildTimeText(BuildContext context) {
    final text = Selector<TodoListState, String>(
      selector: (_, state) => state.counter.timeText,
      builder: (_, value, child) => Text(
        value,
        style: settings["widget.pomodoro.counter.time-text.style"],
      )
    );

    return Container(
      margin: settings["widget.pomodoro.counter.button.margin"],
      child: text,
    );
  }

  Widget buildClickButton(BuildContext context) {
    return Selector<TodoListState, bool>(
      selector: (_, state) => state.counter.state == RunningState.paused,
      builder: (_, value, child) => GestureDetector(
        onTap: () {
          if (value) {
            state.startCountDown();
          } else {
            state.stopCountDown();
          }
        },

        child: Container(
          decoration: settings["widget.pomodoro.counter.button.decoration"],
          height: settings["widget.pomodoro.counter.button.height"],
          width: settings["widget.pomodoro.counter.button.width"],
          margin: settings["widget.pomodoro.counter.button.margin"],
          padding: settings["widget.pomodoro.counter.button.padding"],
          child: Center(
            child: Text(value ? "START" : "STOP", style: settings["widget.pomodoro.counter.button.text-style"],),
          ),
        ),
      ),
    );
  }
}