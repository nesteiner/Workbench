import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/switcher-controller.dart';

class Switcher extends StatefulWidget {
  static final width = settings["widget.daily-attendance.switcher.width"];
  static final height = settings["widget.daily-attendance.switcher.height"];
  static final buttonWidth = settings["widget.daily-attendance.switcher.button.width"];
  static final buttonHeight = settings["widget.daily-attendance.switcher.button.height"];
  static final startLeft = settings["widget.daily-attendance.switcher.button.start-left"];
  static Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  SwitcherController controller;
  void Function(bool) onChanged;
  Duration duration;
  Switcher({required this.controller, required this.onChanged, required this.duration});

  @override
  State<Switcher> createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  bool get value => widget.controller.value;
  late ConfettiController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller.addListener(() {
      setState(() {

      });
    });
    controller = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      alignment: Alignment.center,
      children: [
        buildButton(context),
        ConfettiWidget(
          confettiController: controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],

          createParticlePath: Switcher.drawStar,
        )
      ],
    );
  }


  Widget buildButton(BuildContext context) {
    final button = Container(
      width: Switcher.buttonWidth,
      height: Switcher.buttonHeight,
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

    double left = value ? Switcher.width - Switcher.height : Switcher.startLeft;
    return StatefulBuilder(
        builder: (context, setState) => Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
                duration: widget.duration,
                width: Switcher.width,
                height: Switcher.height,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(Switcher.height / 2)),
                    color: value ? Colors.transparent : Color.fromRGBO(0, 0, 0, 0.1)
                ),
              ),

              AnimatedPositioned(
                duration: widget.duration,
                left: left,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    widget.controller.value = !value;
                    setState(() {
                      if (value) {
                        left = Switcher.width - Switcher.height;
                        controller.play();
                      } else {
                        left = Switcher.startLeft;
                      }
                    });

                    await Future.delayed(widget.duration + const Duration(seconds: 3));
                    widget.onChanged(value);
                  },

                  child: button,
                ),
              )
            ],
          )
    );
  }
}