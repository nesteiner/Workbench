import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:provider/provider.dart';
import 'package:frontend/model/daily-attendance.dart' as da;

class StatisticsPage extends StatefulWidget {
  static final weekdays = ["一", "二", "三", "四", "五", "六", "日"];
  static final weekdayDistance = {
    DateTime.monday: 0,
    DateTime.tuesday: 1,
    DateTime.wednesday: 2,
    DateTime.thursday: 3,
    DateTime.friday: 4,
    DateTime.saturday: 5,
    DateTime.sunday: 6
  };

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  DailyAttendanceState?  _state;

  DailyAttendanceState get state => _state!;

  late void Function(void Function()) setStateChangeWeek;

  late void Function(void Function()) setStateChangeMonth;

  final offsetWeekNotifier = ValueNotifier(0);

  int get offsetWeek => offsetWeekNotifier.value;

  set offsetWeek(int value) {
    assert(value <= 0);
    offsetWeekNotifier.value = value;
  }

  final offsetMonthNotifier = ValueNotifier(0);

  int get offsetMonth => offsetMonthNotifier.value;

  set offsetMonth(int value) {
    assert(value <= 0);
    offsetMonthNotifier.value = value;
  }

  bool isCurrentDay(String weekday) {
    final now = DateTime.now();
    final thisWeekDayIndex = now.weekday - 1;
    return StatisticsPage.weekdays[thisWeekDayIndex] == weekday;
  }

  late final TabBar tabs;

  late final TabController tabController;

  late ValueNotifier<int> tabIndexNotifier;
  int get tabIndex => tabIndexNotifier.value;
  set tabIndex(int value) {
    tabIndexNotifier.value = value;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabIndexNotifier = ValueNotifier(0);
    tabs = TabBar(
      tabs: const [
        Tab(text: "周",),
        Tab(text: "月",)
      ],
      controller: tabController,
      onTap: (index) {
        tabIndex = index;
      },
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _state ??= context.read<DailyAttendanceState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("统计",),
        bottom: tabs,
        leading: BackButton(
          onPressed: () {
            dailyAttendnaceNavigatorKey.currentState?.pop();
            // Navigator.pop(context);

          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: tabIndexNotifier,
        builder: (_, value, child) {
          if (value == 0) {
            return ValueListenableBuilder(
                valueListenable: offsetWeekNotifier,
                builder: (context, value, child) => buildStatisticsWeekly(context, value)
            );
          } else {
            return ValueListenableBuilder(
                valueListenable: offsetMonthNotifier,
                builder: (context, value, child) => buildStatisticsMonthly(context, value)
            );
          }
        },
      )
    );
  }

  Widget buildStatisticsWeekly(BuildContext context, int offset) {
    return FutureBuilder(
        future: state.statisticsWeekly(offset),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            logger.e("build statistics weekly", stackTrace: snapshot.stackTrace);
            return Center(child: Text("error in statistics: ${snapshot.error}"),);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final Map<da.Task, List<da.Progress>> data = snapshot.requireData;
          final head = Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                  flex: 1,
                  child: Container()
              ),

              Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: StatisticsPage.weekdays.map<Widget>(
                            (e) {
                              final flag = isCurrentDay(e);
                              final color = flag ? Colors.white : Colors.black;
                              final style = TextStyle(color: color, fontSize: settings["page.daily-attendance.statistics.week.panel.font.size"]);
                              return Container(
                                width: settings["page.daily-attendance.statistics.week.panel.item.size"],
                                height: settings["page.daily-attendance.statistics.week.panel.item.size"],
                                margin: settings["page.daily-attendance.statistics.panel.item.margin"],
                                decoration: flag ? const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle
                                ) : null,
                                child: Center(child: Text(e, style: style))
                              );
                            }
                    ).toList(),
                  )
              )
            ],
          );

          final keys = data.keys.toList();
          final listview = ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                late Color color;
                final task = keys[index];
                final progresses = data[task]!;

                late Widget icon;

                if (task.icon is da.IconWord) {
                  final icon0 = task.icon as da.IconWord;
                  color = icon0.color;
                  icon = Container(
                    width: settings["page.daily-attendance.statistics.week.panel.item.size"],
                    height: settings["page.daily-attendance.statistics.week.panel.item.size"],
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color
                    ),

                    child: Center(
                      child: Text(icon0.word, style: const TextStyle(color: Colors.white),),),
                  );
                } else {
                  final icon0 = task.icon as da.IconImage;
                  color = icon0.backgroundColor;

                  icon = Container(
                    width: settings["page.daily-attendance.statistics.week.panel.item.size"],
                    height: settings["page.daily-attendance.statistics.week.panel.item.size"],
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color
                    ),

                    child: Center(
                        child: Image.network(state.iconUrl(icon0.entryId))
                    ),
                  );
                }

                final left = Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon,
                      SizedBox(width: settings["common.unit.size"],),
                      Text(task.name, style: TextStyle(fontSize: settings["page.daily-attendance.statistics.week.panel.font.size"]),)
                    ],
                  ),
                );

                final rightChildren = StatisticsPage.weekdays.indexed.map<Widget>((e) {
                  final progress = progresses[e.$1];
                  final itemColor = progressColor(progress, color);
                  return Container(
                    width: settings["page.daily-attendance.statistics.week.panel.item.size"],
                    height: settings["page.daily-attendance.statistics.week.panel.item.size"],
                    margin: settings["page.daily-attendance.statistics.panel.item.margin"],
                    padding: settings["page.daily-attendance.statistics.panel.item.padding"],
                    decoration: BoxDecoration(
                      color: itemColor
                    ),
                  );
                }).toList();

                final right = Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: rightChildren,
                  ),
                );

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    left,
                    right
                  ],
                );
              }
          );

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: settings["page.daily-attendance.statistics.panel.decoration"],
                width: settings["page.daily-attendance.statistics.panel.width"],
                padding: settings["page.daily-attendance.statistics.panel.padding"],
                margin: settings["page.daily-attendance.statistics.panel.margin"],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildChangeWeek(context, data.isEmpty),
                    SizedBox(height: settings["page.daily-attendance.statistics.change-week.margin-bottom"],),
                    head,
                    listview
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget buildChangeWeek(BuildContext context, bool matchLowerBound) {
    final now = DateTime.now();
    final distance = StatisticsPage.weekdayDistance[now.weekday]!;
    final startOfWeek0 = now.subtract(Duration(days: distance));
    final startOfWeek = startOfWeek0.subtract(Duration(days: 7 * offsetWeek));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    late String text;
    if (offsetWeek == 0) {
      text = "本周";
    } else if (offsetWeek == -1) {
      text = "上周";
    } else {
      text = "${formatDate(startOfWeek)} - ${formatDate(endOfWeek)}";
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: matchLowerBound ? null : () {
            offsetWeek -= 1;
          },

          icon: Icon(Icons.arrow_back_ios_rounded, color: matchLowerBound ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
        ),

        Expanded(child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold),))),

        ValueListenableBuilder(
            valueListenable: offsetWeekNotifier,
            builder: (_, value, child) {
              final flag = value == 0;
              return IconButton(
                onPressed: flag ? null : () {
                  offsetWeek += 1;
                },

                icon: Icon(Icons.arrow_forward_ios_rounded, color: flag ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
              );
            }
        )
      ],
    );
  }

  Widget buildStatisticsMonthly(BuildContext context, int offset) {
    return FutureBuilder(
        future: state.statisticsMonthly(offset),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(child: Text("error in build statistics monthly: ${snapshot.error}"),);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final data = snapshot.requireData;
          final gridview = GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1,
            children: data.entries.map((entry) => buildCalendar(context, entry.key, entry.value)).toList(),
          );

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: settings["page.daily-attendance.statistics.panel.padding"],
                margin: settings["page.daily-attendance.statistics.panel.margin"],
                decoration: settings["page.daily-attendance.statistics.panel.decoration"],
                width: settings["page.daily-attendance.statistics.panel.width"],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildChangeMonth(context, data.isEmpty),
                    SizedBox(height: settings["page.daily-attendance.statistics.month.panel.calendar.head.margin-bottom"],),
                    gridview
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  Widget buildCalendar(BuildContext context, da.Task task, List<da.Progress> progresses) {
    late Color color;
    late Widget icon;

    if (task.icon is da.IconWord) {
      final icon0 = task.icon as da.IconWord;
      color = icon0.color;
      icon = Container(
        width: settings["page.daily-attendance.statistics.week.panel.item.size"],
        height: settings["page.daily-attendance.statistics.week.panel.item.size"],
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color
        ),

        child: Center(
          child: Text(icon0.word, style: const TextStyle(color: Colors.white),),),
      );
    } else {
      final icon0 = task.icon as da.IconImage;
      color = icon0.backgroundColor;

      icon = Container(
        width: settings["page.daily-attendance.statistics.week.panel.item.size"],
        height: settings["page.daily-attendance.statistics.week.panel.item.size"],
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color
        ),

        child: Center(
            child: Image.network(state.iconUrl(icon0.entryId))
        ),
      );
    }

    final head = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: settings["common.unit.size"],),
        Text(task.name, style: TextStyle(fontSize: settings["page.daily-attendance.statistics.week.panel.font.size"]),)
      ],
    );


    final children = progresses.map<Widget>((e) => Container(
      width: settings["page.daily-attendance.statistics.month.panel.calendar.item.size"],
      height: settings["page.daily-attendance.statistics.month.panel.calendar.item.size"],
      margin: settings["page.daily-attendance.statistics.month.panel.calendar.item.margin"],
      decoration: BoxDecoration(
        color: progressColor(e, color)
      ),
    )).toList();

    final blank = Container(
      width: settings["page.daily-attendance.statistics.month.panel.calendar.item.size"],
      height: settings["page.daily-attendance.statistics.month.panel.calendar.item.size"],
      margin: settings["page.daily-attendance.statistics.month.panel.calendar.item.margin"],
    );

    children.insert(0, blank);
    children.insert(0, blank);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        head,
        SizedBox(height: settings["page.daily-attendance.statistics.month.panel.calendar.head.margin-bottom"],),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          children: children,
        )
      ],
    );
  }

  Widget buildChangeMonth(BuildContext context, bool matchLowerBound) {
    late String text;
    final now = DateTime.now();
    if (offsetMonth == 0) {
      text = "${now.month}月";
    } else {
      final time = DateTime(now.year, now.month - offsetMonth.abs(), 1);
      text = "${time.year}年${time.month}月";
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: matchLowerBound ? null : () {
            offsetMonth -= 1;
          },

          icon: Icon(Icons.arrow_back_ios_rounded, color: matchLowerBound ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
        ),

        Expanded(child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold),))),

        ValueListenableBuilder(
            valueListenable: offsetMonthNotifier,
            builder: (_, value, child) {
              final flag = value == 0;
              return IconButton(
                onPressed: flag ? null : () {
                  offsetMonth += 1;
                },

                icon: Icon(Icons.arrow_forward_ios_rounded, color: flag ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
              );
            }
        )
      ],
    );
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.year}: ${dateTime.month}月${dateTime.day}日";
  }

  Color progressColor(da.Progress progress, Color color) {
    if (progress is da.ProgressDone) {
      return color;
    } else if (progress is da.ProgressDoing) {
      return color.withOpacity(progress.amount.toDouble() / progress.total);
    } else if (progress is da.ProgressNotScheduled) {
      return const Color.fromRGBO(0, 0, 0, 0.2);
    } else {
      return const Color.fromRGBO(0, 0, 0, 0.05);
    }
  }
}