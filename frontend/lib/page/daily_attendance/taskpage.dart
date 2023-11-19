import 'package:flutter/material.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:provider/provider.dart';


/// TODO
/// 1. add entry
/// 2. add background
/// 3. add color
/// 4. edit entry
/// 5. edit backgorund
/// 6. edit color
class TaskPage extends StatelessWidget {
  late final DailyAttendanceState state;
  @override
  Widget build(BuildContext context) {
    state = context.read<DailyAttendanceState>();

    // TODO: implement build
    throw UnimplementedError();
  }
}