import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class Switcher extends StatelessWidget {
  static final width = settings["widget.daily-attendance.switcher.width"];
  static final height = settings["widget.daily-attendance.switcher.height"];
  static final buttonWidth = settings["widget.daily-attendance.switcher.button.width"];
  static final buttonHeight = settings["widget.daily-attendance.switcher.button.height"];
  static final startLeft = settings["widget.daily-attendance.switcher.button.start-left"];

  bool value;
  void Function(bool) onChanged;
  Duration duration;
  Switcher({required this.value, required this.onChanged, required this.duration});

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
                color: Color.fromRGBO(0, 0, 0, 0.3)
            ),
          ]
      ),

      child: const Center(child: Icon(Icons.check, color: Color.fromRGBO(0, 0, 0, 0.3),),),
    );

    double left = value ? width - height : startLeft;
    return StatefulBuilder(
        builder: (context, setState) => Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
                duration: duration,
                width: width,
                height: height,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                    color: value ? Colors.transparent : Color.fromRGBO(0, 0, 0, 0.1)
                ),
              ),

              AnimatedPositioned(
                duration: duration,
                left: left,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    value = !value;
                    setState(() {
                      if (value) {
                        left = width - height;
                      } else {
                        left = startLeft;
                      }
                    });

                    await Future.delayed(duration + const Duration(milliseconds: 500));
                    onChanged(value);
                  },

                  child: button,
                ),
              )
            ],
          )
    );
  }
}