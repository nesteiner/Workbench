import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/pomodoro.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Pomodoro extends StatefulWidget {
  PomodoroState createState() => PomodoroState();
}

class PomodoroState extends State<Pomodoro> {
  final counter = Counter(pomodoroTime: 25, shortBreakTime: 5, longBreakTime: 15);
  Timer? timer;
  void Function(void Function())? setStatePercentageAndText;
  double _percentage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatefulBuilder(
          builder: (context, setState) {
            setStatePercentageAndText ??= setState;
            return CircularPercentIndicator(
              radius: 120,
              lineWidth: 10,
              percent: _percentage,
              center: Text(counter.timeText, style: settings["widget.home.pomodoro.center.text-style"],),
              progressColor: Colors.blue,
            );
          },
        ),

        SizedBox(height: settings["widget.home.pomodoro.margin"],),

        StatefulBuilder(
          builder: (context, setState) => ElevatedButton(
              onPressed: () {
                if (counter.state == RunningState.running) {
                  setState(() {
                    stopCountDown();
                  });
                } else {
                  setState(() {
                    startCountDown();
                  });
                }
              },

              child: counter.state == RunningState.running ? const Text("暂停") : const Text("开始")
          ),
        )
      ],
    );
  }

  void startCountDown() {
    counter.isfinished = false;
    timer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (counter.isfinished) {
        timer.cancel();
      } else {
        setStatePercentageAndText!(() {
          counter.countDownOnce();
          _percentage = percentage();
        });
      }
    });
  }

  void stopCountDown() {
    setStatePercentageAndText!(() {
      counter.state = RunningState.paused;
      timer?.cancel();
      _percentage = percentage();
    });
  }

  double percentage() {
    int total = 0;
    if (counter.focusState == FocusState.pomodoro) {
      total = 25 * 60;
    } else if (counter.focusState == FocusState.shortBreak) {
      total = 5 * 60;
    } else {
      total = 15 * 60;
    }

    return (counter.currentTime[0] * 60 + counter.currentTime[1]).toDouble() / total;
  }
}