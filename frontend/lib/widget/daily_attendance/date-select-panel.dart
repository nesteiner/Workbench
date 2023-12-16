import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:provider/provider.dart';

class DateSelectPanel extends StatelessWidget {
  static final weekdayMap = {
    "SUNDAY": "日",
    "MONDAY": "一",
    "TUESDAY": "二",
    "WEDNESDAY": "三",
    "THURSDAY": "四",
    "FRIDAY": "五",
    "SATURDAY": "六"
  };

  late final List<String> weekdays;
  late final List<int> days;
  late final DailyAttendanceState state;

  DateSelectPanel() {
    final lastDay = DateTime.now();
    final prev6Day = lastDay.subtract(const Duration(days: 6));
    days = [];
    DateTime currentTime = prev6Day;
    final end = lastDay.add(const Duration(days: 1));
    while (currentTime.isBefore(end)) {
      days.add(currentTime.day);
      currentTime = currentTime.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    state = context.read<DailyAttendanceState>();
    weekdays = state.weekdays;

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: weekdays
            .indexed
            .map((e) => e.$1)
            .map((e) => Flexible(flex: 1, fit: FlexFit.tight, child: buildItem(context, e)))
            .toList(),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Selector<DailyAttendanceState, String?>(
      selector: (_, state) => state.currentDay,
      builder: (_, value, child) {
        final isselect = value == weekdays[index];
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(weekdayMap[weekdays[index]]!),
              SizedBox(height: settings["widget.daily-attendance.date-select-panel.item.inner.margin-bottom"],),
              InkWell(
                onTap: () {
                  state.setCurrentDay(weekdays[index]);
                },

                customBorder: const CircleBorder(),

                child: Container(
                  padding: settings["widget.daily-attendance.date-select-panel.item.day.padding"],
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isselect ? Colors.blue : Colors.transparent
                  ),
                  child: Text(days[index].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: isselect ? Colors.white : Colors.black),),
                ),
              )

            ],
        );
      },
    );


  }
}