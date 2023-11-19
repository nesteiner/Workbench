import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class WeekdaysCheckbox extends StatelessWidget {
  static final weekdays0 = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];
  static final weekdays1 = ["一", "二", "三", "四", "五", "六", "日"];

  final List<String> weekdays;
  late final List<bool> flags;

  final void Function(List<String>) onChanged;

  WeekdaysCheckbox({required this.onChanged, required this.weekdays}) {
    flags = weekdays0.map((e) => weekdays.contains(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: settings["widget.daily-attendance.checkbox.wrapper.padding"],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: weekdays0.indexed.map<Widget>((e) => buildItem(context, e.$1)).toList(),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    late void Function(void Function()) setStateItem;
    return InkWell(
      onTap: () {
        setStateItem(() {
          flags[index] = !flags[index];
        });

        final weekdays1 = weekdays0.indexed.where((element) => flags[element.$1]).map((element) => element.$2).toList();
        onChanged(weekdays1);
      },

      child: StatefulBuilder(
        builder: (context, setState) {
          setStateItem = setState;

          return Container(
            margin: settings["widget.daily-attendance.checkbox.margin"],
            padding: settings["widget.daily-attendance.checkbox.padding"],
            decoration: BoxDecoration(
                color: flags[index] ? Colors.blue : Color.fromRGBO(0, 0, 0, 0.1),
                shape: BoxShape.circle
            ),

            child: Text(weekdays1[index], style: TextStyle(color: flags[index] ? Colors.white : Colors.black),),
          );
        },
      ),
    );
  }
}