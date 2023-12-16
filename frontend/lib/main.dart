import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/page/error-page.dart';
import 'package:frontend/page/loading-page.dart';
import 'package:frontend/state/clipboard-state.dart';
import 'package:frontend/state/global-state.dart';
import 'package:frontend/page/login-page.dart';
import 'package:frontend/page/preload-page.dart';
import 'package:frontend/page/root-page.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/login-state.dart';
import 'package:frontend/state/samba-state.dart';
import 'package:frontend/state/todolist-state.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

          )
        )
      ),
      home: FutureBuilder(
        future: GlobalState.loadGlobalState(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorPage(error: snapshot.error, stackTrace: snapshot.stackTrace,);
          }

          if (!snapshot.hasData) {
            return const LoadingPage();
          }

          final state = snapshot.requireData;

          return ChangeNotifierProvider(
            create: (_) => state,
            child: Selector<GlobalState, (LoginState?, TodoListState?, DailyAttendanceState?, SambaState?, ClipboardState?)>(
              selector: (_, state) => (state.loginState, state.todolistState, state.dailyAttendanceState, state.sambaState, state.clipboardState),
              builder: (_, value, child) {
                final List<SingleChildWidget> providers = [];
                if (value.$1 != null) {
                  providers.add(ChangeNotifierProvider(create: (_) => value.$1!));
                }

                if (value.$2 != null) {
                  providers.add(ChangeNotifierProvider(create: (_) => value.$2!));
                }

                if (value.$3 != null) {
                  providers.add(ChangeNotifierProvider(create: (_) => value.$3!));
                }

                if (value.$4 != null) {
                  providers.add(ChangeNotifierProvider(create: (_) => value.$4!));
                }

                if (value.$5 != null) {
                  providers.add(ChangeNotifierProvider(create: (_) => value.$5!));
                }

                if (providers.isEmpty) {
                  return buildPage(context, state);
                } else {
                  return MultiProvider(providers: providers, child: buildPage(context, state),);
                }
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget buildPage(BuildContext context, GlobalState state) {
    late Widget page;

    if (!(state.isconfigured ?? false)) {
      page = PreloadPage();
    } else {
      final jwttoken = state.jwttoken;
      if (jwttoken == null) {
        page = LoginPage();
      } else {
        page = RootPage();
      }
    }

    return page;
  }
}


