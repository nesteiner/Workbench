import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

enum FocusState {
  pomodoro,
  shortBreak,
  longBreak
}

enum RunningState {
  paused,
  running
}

class Counter {
  int pomodoroTime;
  int shortBreakTime;
  int longBreakTime;

  FocusState focusState = FocusState.pomodoro;
  int interval = 0;
  bool isfinished = false;
  AudioPlayer audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.release);
  AssetSource musicUrl = AssetSource("notification.mp3");


  late List<int> currentTime; // [minutes, seconds]
  late int longBreakInterval;
  late RunningState state;
  late Duration duration;

  Counter({
    required this.pomodoroTime,
    required this.shortBreakTime,
    required this.longBreakTime,
    this.longBreakInterval = 4,
    this.duration = const Duration(seconds: 3)
  }) {
    state = RunningState.paused;
    currentTime = [1, 0];
    setFocusState(focusState);
  }

  void countDownOnce() {
    state = RunningState.running;
    currentTime[1] -= 1;
    if(currentTime[1] == -1) {
      if(currentTime[0] != 0) {
        currentTime[1] = 59;
        currentTime[0] -= 1;
      } else {
        currentTime[1] = 0;
        isfinished = true;
        state = RunningState.paused;

        audioPlayer.play(musicUrl);
        Timer(duration, () async {
          await audioPlayer.release();
        });

        if(focusState == FocusState.pomodoro) {
          interval += 1;

          if(interval % longBreakInterval == 0) {
            setFocusState(FocusState.longBreak);
          } else {
            setFocusState(FocusState.shortBreak);
          }
        } else {
          setFocusState(FocusState.pomodoro);
        }
      }
    }
  }

  void setFocusState(FocusState focusState) {
    this.focusState = focusState;
    currentTime[1] = 0;

    if (focusState == FocusState.pomodoro) {
      currentTime[0] = pomodoroTime;
    } else if (focusState == FocusState.shortBreak) {
      currentTime[0] = shortBreakTime;
    } else {
      currentTime[0] = longBreakTime;
    }
  }

  String get timeText => "${zeroPadding(currentTime[0])}:${zeroPadding(currentTime[1])}";

  String zeroPadding(int number) {
    if (number < 10) {
      return "0$number";
    } else {
      return "$number";
    }
  }
}