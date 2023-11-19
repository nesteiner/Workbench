import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class Switcher extends StatelessWidget {
  bool value;
  void Function(void Function()) onChanged;

  Switcher({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final icon0 = Container(
      width: settings["widget.daily-attendance.switcher.icon.size"],
      height: settings["widget.daily-attendance.switcher.icon.size"],
      decoration: BoxDecoration(
        shape: BoxShape.circle
      ),
      child: Image.asset("assets/switch-ok", color: Colors.white,),
    );

    final slot = Container(
      width: settings["widget.daily-attendance.switcher.slot.width"],
      height: settings["widget.daily-attendance.switcher.icon.size"],
      decoration: BoxDecoration(
        color: settings["widget.daily-attendance.switcher.slot.background-color"]
      ),
    );

    return StatefulBuilder(builder: (context, setState) => Stack(
      children: [
        slot,
        GestureDetector(
          onTap: () {
            setState(() => value = !value);
          },

          child: SizedBox.shrink(),
        ),
      ],
    ));
  }
}