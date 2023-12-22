import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/state/user-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/state/todolist-state.dart';

mixin StateMixin {
  GlobalState? _globalState;
  GlobalState get globalState => _globalState!;
  set globalState(GlobalState value) => _globalState ??= value;

  UserState? _userState;
  UserState get userState => _userState!;
  set userState(UserState value) => _userState ??= value;

  TodoListState? _todoListState;
  TodoListState get todolistState => _todoListState!;
  set todolistState(TodoListState value) => _todoListState ??= value;

  DailyAttendanceState? _dailyAttendanceState;
  DailyAttendanceState get dailyAttendanceState => _dailyAttendanceState!;
  set dailyAttendanceState(DailyAttendanceState value) => _dailyAttendanceState ??= value;

  SambaState? _sambaState;
  SambaState get sambaState => _sambaState!;
  set sambaState(SambaState value) => _sambaState ??= value;

  ClipboardState? _clipboardState;
  ClipboardState get clipboardState => _clipboardState!;
  set clipboardState(ClipboardState value) => _clipboardState ??= value;
}