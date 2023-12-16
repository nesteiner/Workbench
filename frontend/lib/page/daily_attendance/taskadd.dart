import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/page/daily_attendance/color-select.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/state/daily-attendance-state.dart';
import 'package:frontend/state/login-state.dart';
import 'package:frontend/widget/daily_attendance/checkbox.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class TaskAdd extends StatelessWidget {
  static final units = [
    "次", "杯", "毫升", "分钟", "小时", "公里"
  ];
  static final positiveRegex = RegExp(r"^[1-9]\d*$");

  late final LoginState loginState;
  late final PostDailyAttendanceTaskRequest request;
  late final DailyAttendanceState dailyAttendanceState;

  Color? color;

  Color get backgroundColor => color ?? ColorSelect.defaultColor;
  set backgroundColor(Color? color0) => color = color0;

  int entryid = -1;
  int backgroundid = -1;

  bool get step1Enable {
    final flag1 = nameController.text.isNotEmpty &&
        encouragementController.text.isNotEmpty;
    final flag2 = imageNotifier.value.entry != null &&
        imageNotifier.value.background != null;
    final flag3 = wordController.text.isNotEmpty;

    return flag1 && (flag2 || flag3);
  }

  final modeNotifier = ValueNotifier(da.IconMode.image);
  final imageNotifier = ValueNotifier(da.ImageCompose());
  final step1DisabledNotifier = ValueNotifier(true);

  late void Function(void Function()) setStateAddIcon;
  late void Function(void Function()) setStateBackgroundColor;

  final nameController = TextEditingController(text: "");
  final encouragementController = TextEditingController(text: "");
  final wordController = TextEditingController(text: "");
  TaskAdd({this.color});

  @override
  Widget build(BuildContext context) {
    loginState = context.read<LoginState>();
    dailyAttendanceState = context.read<DailyAttendanceState>();
    int userid = loginState.userid;
    request = PostDailyAttendanceTaskRequest(
        name: "",
        icon: da.IconWord(word: "文", color: color ?? Colors.blue),
        encouragement: "",
        frequency: da.FrequencyDays(weekdays: WeekdaysCheckbox.weekdays0),
        goal: da.GoalCurrentDay(),
        startTime: DateTime.now(),
        keepdays: da.KeepDaysForever(),
        group: da.Group.noon,
        notifyTimes: [],
        userid: userid
    );

    return buildStep1(context);
  }

  Widget buildStep1(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("新习惯"),),
      body: buildStep1Body(context),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: step1DisabledNotifier,
        builder: (context, value, child) => FloatingActionButton(
          onPressed: value ? null : () {
            if (modeNotifier.value == da.IconMode.image) {
              request.icon = da.IconImage(entryId: entryid, backgroundId: backgroundid, backgroundColor: backgroundColor);
            } else {
              request.icon = da.IconWord(word: wordController.text, color: backgroundColor);
            }

            dailyAttendnaceNavigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => buildStep2(context)));
          },

          child: const Text("下一步"),
        ),
      ),
    );
  }

  Widget buildStep1Body(BuildContext context) {
    final nameTextField = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("习惯名称"),
        SizedBox(height: settings["page.daily-attendance.taskedit.edit-name-icon.margin-bottom"],),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            border: UnderlineInputBorder()
          ),

          onChanged: (value) {
            request.name = value;
            step1DisabledNotifier.value = !step1Enable;
          },
        )
      ],
    );

    final nameWidget = Container(
      decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
      padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
      margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
      child: nameTextField,
    );

    final switchsAndColor = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () => modeNotifier.value = da.IconMode.image,
                icon: ValueListenableBuilder(
                  valueListenable: modeNotifier,
                  builder: (context, value, child) {
                    Color? color;
                    if (value == da.IconMode.image) {
                      color = Colors.blue;
                    }

                    return Icon(Icons.image_outlined, color: color,);
                  },
                )
            ),

            IconButton(
              onPressed: () => modeNotifier.value = da.IconMode.word,
              icon: ValueListenableBuilder(
                valueListenable: modeNotifier,
                builder: (context, value, child) {
                  Color? color;
                  if (value == da.IconMode.word) {
                    color = Colors.blue;
                  }

                  return Icon(Icons.font_download_outlined, color: color,);
                },
              ),
            ),

          ],
        ),

        buildIconAddBackgroundColor(context)
      ],
    );

    final iconWidget = Container(
      decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
      padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
      margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("图标"),
          SizedBox(height: settings["page.daily-attendance.taskedit.edit-name-icon.margin-bottom"],),
          switchsAndColor,
          SizedBox(height: settings["page.daily-attendance.taskedit.edit-name-icon.margin-bottom"],),
          ValueListenableBuilder(
              valueListenable: modeNotifier,
              builder: (context, value, child) {
                if (value == da.IconMode.image) {
                  return buildIconEditImage(context);
                } else {
                  return buildIconEditWord(context);
                }
              }
          )
        ],
      ),
    );



    final encouragementWidget = Container(
      decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
      padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
      margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("鼓励语"),
          SizedBox(height: settings["page.daily-attendance.taskedit.edit-name-icon.margin-bottom"],),
          TextField(
            controller: encouragementController,
            onChanged: (value) {
              request.encouragement = value;
              step1DisabledNotifier.value = !step1Enable;
            },
          )
        ],
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          nameWidget,
          iconWidget,
          encouragementWidget
        ],
      ),
    );
  }

  Widget buildStep2(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("新习惯"),),
      body: buildStep2Body(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await dailyAttendanceState.insertTask(request);
          // TODO later to replace the route path
          // navigatorKey.currentState?.popUntil(ModalRoute.withName("/daily-attendance"));
          // Navigator.pop(context);
          // Navigator.pop(context);

          dailyAttendnaceNavigatorKey.currentState?.popUntil(ModalRoute.withName(dailyAttendanceRoutes["taskpage"]!));
        },

        child: const Text("保存"),
      ),
    );
  }

  Widget buildStep2Body(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskEditFrequency(request: request),
          buildEditGoalAndStartTimeAndKeepDays(context),
          buildEditGroup(context),
          buildEditNotifyTimes(context),
        ],
      ),
    );
  }

  Widget buildIconEditImage(BuildContext context) {
    final uploadEntry = ValueListenableBuilder(
        valueListenable: imageNotifier,
        builder: (context, value, _child) {
          late Widget child;
          if (value.entry == null) {
            child = Icon(Icons.add, size: settings["page.daily-attendance.taskedit.image-pick-upload.item.icon.size"],);
          } else {
            child = imageNotifier.value.entry!;
          }

          return Container(
            width: settings["page.daily-attendance.taskedit.image-pick-upload.item.size"],
            height: settings["page.daily-attendance.taskedit.image-pick-upload.item.size"],
            decoration: settings["page.daily-attendance.taskedit.image-pick-upload.item.decoration"],
            child: Center(
                child: child
            ),
          );
        }
    );

    final uploadBackground = ValueListenableBuilder(
        valueListenable: imageNotifier,
        builder: (context, value, _child) {
          late Widget child;

          if (value.background == null) {
            child = Icon(Icons.add, size: settings["page.daily-attendance.taskedit.image-pick-upload.item.icon.size"]);
          } else {
            child = imageNotifier.value.background!;
          }

          return Container(
            width: settings["page.daily-attendance.taskedit.image-pick-upload.item.size"],
            height: settings["page.daily-attendance.taskedit.image-pick-upload.item.size"],
            decoration: settings["page.daily-attendance.taskedit.image-pick-upload.item.decoration"],
            child: Center(
              child: child,
            ),
          );
        }
    );

    final uploadEntryButton = TextButton(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["png"]);
        if (result != null) {
          final path = result.files.single.path as String;

          imageNotifier.value = imageNotifier.value.copyWith(entry: Image.file(
            File(path),
            width: settings["widget.daily-attendance.image-pick-upload.item.size"],
            height: settings["widget.daily-attendance.image-pick-upload.item.size"],
          ));

          final file = await MultipartFile.fromFile(path);
          final image = await dailyAttendanceState.uploadImage(file);

          entryid = image.id;
        }
      },

      child: const Text("添加图标"),
    );

    final uploadBackgroundButton = TextButton(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["png"]);
        if (result != null) {
          final path = result.files.single.path as String;

          imageNotifier.value = imageNotifier.value.copyWith(background: Image.file(
            File(path),
            width: settings["widget.daily-attendance.image-pick-upload.item.size"],
            height: settings["widget.daily-attendance.image-pick-upload.item.size"],
          ));


          final file = await MultipartFile.fromFile(path);
          final image = await dailyAttendanceState.uploadImage(file);

          backgroundid = image.id;
        }
      },

      child: const Text("添加背景图片"),
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            uploadEntry,
            uploadEntryButton
          ],
        ),

        SizedBox(width: settings["page.daily-attendance.taskedit.image-pick-upload.item.margin"]),

        Column(
          children: [
            uploadBackground,
            uploadBackgroundButton
          ],
        )
      ],
    );
  }

  Widget buildIconAddBackgroundColor(BuildContext context) {
    final icon = StatefulBuilder(builder: (context, setState) {
      setStateBackgroundColor = setState;

      return Container(
        width: settings["widget.daily-attendance.task.icon.size"],
        height: settings["widget.daily-attendance.task.icon.size"],
        decoration: BoxDecoration(
          color: backgroundColor,
        ),

        child: const Center(child: Text("颜色", style: const TextStyle(color: Colors.white),),),
      );
    });

    return InkWell(
      onTap: () async {
        // final result = await navigatorKey.currentState?.push<Color?>(MaterialPageRoute(builder: (_) => ColorSelect()));
        final result = await dailyAttendnaceNavigatorKey.currentState?.pushNamed<Color?>(dailyAttendanceRoutes["color-select"]!);
        if (result != null) {
          setStateBackgroundColor(() {
            backgroundColor = result;
          });

          final icon0 = request.icon;
          if (icon0 is da.IconWord) {
            final icon1 = icon0 as da.IconWord;
            icon1.color = backgroundColor;
          } else {
            final icon1 = icon0 as da.IconImage;
            icon1.backgroundColor = backgroundColor;
          }
        }
      },

      child: icon,
    );
  }

  Widget buildIconEditWord(BuildContext context) {

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: TextField(
            controller: wordController,
            maxLength: 1,
            onChanged: (value) {
              step1DisabledNotifier.value = !step1Enable;
            },

            decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "输入任务名称"
            )
        ))

      ],
    );
  }

  Widget buildEditGoalAndStartTimeAndKeepDays(BuildContext context) {
    return Container(
      decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
      margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
            child: buildEditGoal(context),
          ),

          Padding(
            padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
            child: buildEditStartTime(context),
          ),

          Padding(
            padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
            child: buildEditKeepDays(context),
          )
        ],
      ),
    );
  }

  Widget buildEditGoal(BuildContext context) {
    late String text;
    late void Function(void Function()) setStateText;

    if (request.goal is da.GoalCurrentDay) {
      text = "当天完成一次";
    } else {
      final amount = request.goal as da.GoalAmount;
      text = "${amount.eachAmount}${amount.unit}/天";
    }

    final row = StatefulBuilder(
      builder: (context, setState) {
        setStateText = setState;
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("目标"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: const TextStyle(color: Color.fromRGBO(0, 0, 0, 0.3)),),
                SizedBox(width: settings["common.unit.size"],),
                const Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(0, 0, 0, 0.2),)
              ],
            )

          ],
        );
      },
    );

    return InkWell(
      onTap: () async {
        final goal = await showDialogEditGoal(context, );

        if (goal != null) {
          setStateText(() {
            request.goal = goal;
            if (goal is da.GoalCurrentDay) {
              text = "当天完成一次";
            } else {
              final amount = goal as da.GoalAmount;
              text = "${amount.eachAmount}${amount.unit}/天";
            }
          });
        }
      },

      child: row,
    );
  }

  Widget buildEditStartTime(BuildContext context) {
    const text = Text("开始日期");

    late void Function(void Function()) setStateText;

    final startTime = request.startTime;
    final row = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        text,

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
                builder: (context, setState) {
                  setStateText = setState;
                  return Text("${startTime.month}月${startTime.day}日", style: const TextStyle(color: Color.fromRGBO(0, 0, 0, 0.3),));
                }
            ),

            SizedBox(width: settings["common.unit.size"],),
            const Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(0, 0, 0, 0.2),)
          ],
        )
      ],
    );

    return InkWell(
      onTap: () async {
        final firstDate = DateTime(startTime.year, startTime.month, 1);

        final datetime = await showDatePicker(
            context: context,
            initialDate: startTime,
            firstDate: firstDate,
            lastDate: DateTime(startTime.year + 1)
        );

        if (datetime != null) {
          setStateText(() {
            request.startTime = datetime;
          });
        }
      },

      child: row,
    );
  }

  Widget buildEditKeepDays(BuildContext context) {
    final keepdays = ValueNotifier<da.KeepDays>(request.keepdays.copy());

    const text = Text("坚持天数");

    final row = ValueListenableBuilder(
      valueListenable: keepdays,

      builder: (context, value, child) {
        late String s;

        if (value is da.KeepDaysForever) {
          s = "永远";
        } else {
          final manual = value as da.KeepDaysManual;
          s = "${manual.days}天";
        }

        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            text,

            Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(s, style: const TextStyle(color: Color.fromRGBO(0, 0, 0, 0.3)),),
                SizedBox(width: settings["common.unit.size"],),
                const Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(0, 0, 0, 0.2),)
              ],
            )
          ],
        );
      },
    );

    return InkWell(
      onTap: () {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text("坚持天数", style: TextStyle(fontWeight: FontWeight.bold),),
          content: ValueListenableBuilder(
            valueListenable: keepdays,
            builder: (context, value, child) {
              return Align(
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<da.KeepDays>(
                          value: da.KeepDaysForever(),
                          groupValue: value,

                          onChanged: (value) {
                            if (value != null) {
                              keepdays.value = value;
                            }
                          },
                        ),

                        const Text("永远")
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<da.KeepDays>(
                          value: da.KeepDaysManual(days: 7),
                          groupValue: value,
                          onChanged: (value) {
                            if (value != null) {
                              keepdays.value = value;
                            }
                          },
                        ),

                        const Text("7天")
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<da.KeepDays>(
                          value: da.KeepDaysManual(days: 21),
                          groupValue: value,
                          onChanged: (value) {
                            if (value != null) {
                              keepdays.value = value;
                            }
                          },
                        ),

                        const Text("21天")
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<da.KeepDays>(
                          value: da.KeepDaysManual(days: 30),
                          groupValue: value,
                          onChanged: (value) {
                            if (value != null) {
                              keepdays.value = value;
                            }
                          },
                        ),

                        const Text("30天")
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<da.KeepDays>(
                          value: da.KeepDaysManual(days: 100),
                          groupValue: value,
                          onChanged: (value) {
                            if (value != null) {
                              keepdays.value = value;
                            }
                          },
                        ),

                        const Text("100天")
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<da.KeepDays>(
                          value: da.KeepDaysManual(days: 365),
                          groupValue: value,
                          onChanged: (value) {
                            if (value != null) {
                              keepdays.value = value;
                            }
                          },
                        ),

                        const Text("365天")
                      ],
                    )
                  ],
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                keepdays.value = request.keepdays.copy();
                dailyAttendnaceNavigatorKey.currentState?.pop();
                // Navigator.pop(context);
              },

              child: const Text("取消"),
            ),

            TextButton(
              onPressed: () {
                request.keepdays = keepdays.value;
                dailyAttendnaceNavigatorKey.currentState?.pop();
                // Navigator.pop(context);
              },

              child: const Text("确定"),
            )
          ],
        ),);
      },

      child: row,
    );
  }

  Future<da.Goal?> showDialogEditGoal(BuildContext context) async {
    late da.Goal goal;
    actions(BuildContext context) => [
      TextButton(
        onPressed: () {
          dailyAttendnaceNavigatorKey.currentState?.pop();
          // Navigator.pop(context);
        },

        child: const Text("取消"),
      ),

      TextButton(
        onPressed: () {
          dailyAttendnaceNavigatorKey.currentState?.pop(goal);
          // Navigator.pop(context, goal);
        },

        child: const Text("确定"),
      )
    ];


    return await showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("目标", style: TextStyle(fontWeight: FontWeight.bold),),
      content: buildEditGoalContent(context, (value) {
        goal = value;
      }),

      actions: actions(context),
    ));
  }

  Widget buildEditGoalContent(BuildContext context, void Function(da.Goal) onChanged) {
    // 1. GoalCurrentDay
    // 2. GoalAmount
    final goaltype = ValueNotifier(request.goal is da.GoalCurrentDay ? 1 : 2);
    da.Goal resultGoal = da.GoalCurrentDay();

    late String textTotal;
    late String textEachAmount;
    String unit = units.first;
    final goal = request.goal;

    if (goal is da.GoalAmount) {
      textTotal = goal.total.toString();
      textEachAmount = goal.eachAmount.toString();
      unit = goal.unit;
    } else {
      textTotal = "1";
      textEachAmount = "1";
      unit = "次";
    }

    final radios = ValueListenableBuilder(valueListenable: goaltype, builder: (context, value, child) => Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<int>(value: 1, groupValue: value, onChanged: (value) {
                if (value != null) {
                  goaltype.value = value;
                  resultGoal = da.GoalCurrentDay();
                  onChanged(resultGoal);
                }
              },),

              const Text("当天完成打卡")
            ],
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<int>(value: 2, groupValue: value, onChanged: (value) {
                if (value != null) {
                  goaltype.value = value;
                  resultGoal = da.GoalAmount(total: int.parse(textTotal), unit: unit, eachAmount: int.parse(textEachAmount));

                  onChanged(resultGoal);
                }
              },),

              const Text("当天完成一定量")
            ],
          )
        ],
      ),
    ));



    final totalController = TextEditingController(text: textTotal);
    final eachAmountController = TextEditingController(text: textEachAmount);

    final editpart = StatefulBuilder(builder: (context, setState) {

      final eachday = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("每天"),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: settings["page.daily-attendance.taskedit.edit-goal.textfield.width.0"],
                child: TextField(
                  decoration: null,
                  controller: totalController,
                  keyboardType: TextInputType.number,

                  onChanged: (value) {
                    if (value.isNotEmpty && positiveRegex.hasMatch(value)) {
                      setState(() {
                        textTotal = value;
                        resultGoal = da.GoalAmount(total: int.parse(textTotal), unit: unit, eachAmount: int.parse(textEachAmount));

                        onChanged(resultGoal);
                      });
                    }
                  },
                ),
              ),

              SizedBox(width: settings["common.unit.size"],),
              DropdownButton<String>(
                value: unit,
                items: units.map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                )).toList(),

                onChanged: (value) {
                  if (value != null && positiveRegex.hasMatch(value)) {
                    setState(() {
                      unit = value;
                      resultGoal = da.GoalAmount(total: int.parse(textTotal), unit: value, eachAmount: int.parse(textEachAmount));
                      onChanged(resultGoal);
                    });
                  }
                },
              )
            ],
          )
        ],
      );

      final eachamount = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text("每次记录 ($unit)"),
          SizedBox(
            width: settings["page.daily-attendance.taskedit.edit-goal.textfield.width.1"],
            child: TextField(
              decoration: null,
              controller: eachAmountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    textEachAmount = value;
                    resultGoal = da.GoalAmount(total: int.parse(textTotal), unit: unit, eachAmount: int.parse(textEachAmount));
                    onChanged(resultGoal);
                  });
                }
              },
            ),
          )
        ],
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          eachday,
          eachamount
        ],
      );
    });

    return ValueListenableBuilder(
        valueListenable: goaltype,
        builder: (context, value, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            radios,
            SizedBox(height: settings["page.daily-attendance.taskedit.edit-goal.margin-bottom"],),

            Offstage(
              offstage: value != 2,
              child: editpart,
            )
          ],
        )
    );


  }

  Widget buildEditGroup(BuildContext context) {
    List<bool> flags = List.generate(4, (index) => false);
    // initialize
    switch (request.group) {
      case da.Group.noon:
        flags[0] = true;
        break;

      case da.Group.afternoon:
        flags[1] = true;
        break;

      case da.Group.night:
        flags[2] = true;
        break;

      case da.Group.other:
        flags[3] = true;
        break;
    }

    final names = ["上午", "中午", "晚上", "其他"];

    return Container(
        decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
        padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
        margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("所属分组"),
            SizedBox(height: settings["page.daily-attendance.taskedit.edit-group.title.margin-bottom"],),
            StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: names.indexed.map((e) => buildEditGroupItem(context, e.$1, e.$2, flags, setState)).toList()
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget buildEditGroupItem(BuildContext context, int index, String name, List<bool> flags, void Function(void Function()) setState) {
    return InkWell(
      onTap: () {
        setState(() {
          bool flag = !flags[index];
          flags.fillRange(0, 4, false);

          flags[index] = flag;

          switch (index) {
            case 0:
              request.group = da.Group.noon;
              break;

            case 1:
              request.group = da.Group.afternoon;
              break;

            case 2:
              request.group = da.Group.night;
              break;

            case 3:
              request.group = da.Group.other;
              break;
          }
        });
      },

      child: Container(
        padding: settings["page.daily-attendance.taskedit.edit-group.item.padding"],
        margin: settings["page.daily-attendance.taskedit.edit-group.item.margin"],
        decoration: BoxDecoration(
            color: flags[index] ? Colors.blue : Color.fromRGBO(0, 0, 0, 0.08),
            borderRadius: settings["page.daily-attendance.taskedit.edit-group.item.border-radius"]
        ),

        child: Text(name, style: TextStyle(color: flags[index] ? Colors.white : Colors.black),),
      ),
    );
  }

  /// edit notifyTImes
  Widget buildEditNotifyTimes(BuildContext context) {
    final times = request.notifyTimes;
    late void Function(void Function()) setStateEditTimes;

    final addbutton = TextButton(
      onPressed: () async {
        final initialTime = TimeOfDay.now();
        final timeOfDay = await showTimePicker(context: context, initialTime: initialTime);

        if (timeOfDay != null) {
          setStateEditTimes(() {
            times.add(da.NotifyTime(hour: timeOfDay.hour, minute: timeOfDay.minute));
          });

        }
      },

      child: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Text("添加")
        ],
      ),
    );

    final child = StatefulBuilder(
      builder: (context, setState) {
        setStateEditTimes = setState;
        final widgets = times.map<Widget>((e) => buildEditNotifyTimeItem(context, e, setState)).toList();

        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...widgets,
            addbutton
          ],
        );
      },
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("提醒"),
        SizedBox(height: settings["page.daily-attendance.taskedit.edit-group.title.margin-bottom"],),

        child
      ],
    );

    return Container(
      decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
      padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
      margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
      width: double.infinity,
      child: column,
    );
  }

  Widget buildEditNotifyTimeItem(BuildContext context, da.NotifyTime time, void Function(void Function()) setState) {
    return InkWell(
      onTap: () async {
        final initialTime = TimeOfDay(hour: time.hour, minute: time.minute);
        final timeOfDay = await showTimePicker(
            context: context,
            initialTime: initialTime,
            cancelText: "清除",

            builder: (context, child) => PopScope(
              canPop: false,
              child: child!,
            )
        );

        if (timeOfDay == null) {
          setState(() {
            request.notifyTimes.removeWhere((element) => element == time);
          });
        } else {
          setState(() {
            final index = request.notifyTimes.indexWhere((element) => element == time);
            request.notifyTimes[index] = da.NotifyTime(hour: timeOfDay.hour, minute: timeOfDay.minute);
          });
        }
      },

      child: Container(
        padding: settings["page.daily-attendance.taskedit.edit-notify-times.item.padding"],
        margin: settings["page.daily-attendance.taskedit.edit-notify-times.item.margin"],
        decoration: settings["page.daily-attendance.taskedit.edit-notify-times.item.decoration"],
        child: Text(time.toString()),
      ),
    );
  }

}

class TaskEditFrequency extends StatefulWidget {
  final PostDailyAttendanceTaskRequest request;

  TaskEditFrequency({required this.request});

  @override
  TaskEditFrequencyState createState() {
    return TaskEditFrequencyState();
  }
}

class TaskEditFrequencyState extends State<TaskEditFrequency> with SingleTickerProviderStateMixin {
  late TabController controller;
  final selectedColor = const Color(0xff1a73e8);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);

    if (widget.request.frequency is da.FrequencyDays) {
      controller.index = 0;
    } else if (widget.request.frequency is da.FrequencyCountInWeek) {
      controller.index = 1;
    } else {
      controller.index = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = controller.index;
    late void Function(void Function()) setStateSwitch;
    final tabs = [
      Tab(text: "按天"),
      Tab(text: "按周"),
      Tab(text: "按时间间隔")
    ];

    final tabbar = Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        controller: controller,
        tabs: tabs,
        labelColor: selectedColor,
        indicatorColor: selectedColor,
        indicatorSize: TabBarIndicatorSize.label,
        isScrollable: true,
        tabAlignment: TabAlignment.start,

        onTap: (index) {
          setStateSwitch(() {
            selectedIndex = index;
          });
        },
      ),
    );

    final tabbody = StatefulBuilder(builder: (context, setState) {
      setStateSwitch = setState;

      if (selectedIndex == 0) {
        return buildFrequencyDays(context);
      } else if (selectedIndex == 1) {
        return buildFrequencyCountInWeek(context);
      } else {
        return buildFrequncyInterval(context);
      }
    });

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        tabbar,
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: settings["page.daily-attendance.taskedit.tabbody.min-height"],
              maxHeight: settings["page.daily-attendance.taskedit.tabbody.max-height"]
          ),

          child: tabbody,
        )
      ],
    );

    return Container(
      decoration: settings["page.daily-attendance.taskedit.wrapper.decoration"],
      padding: settings["page.daily-attendance.taskedit.wrapper.padding"],
      margin: settings["page.daily-attendance.taskedit.wrapper.margin"],
      child: column,
    );
  }

  Widget buildFrequencyDays(BuildContext context) {
    late List<String > weekdays1;

    if (widget.request.frequency is da.FrequencyDays) {
      final frequency = widget.request.frequency as da.FrequencyDays;
      weekdays1 = frequency.weekdays;
    } else {
      weekdays1 = WeekdaysCheckbox.weekdays0;
    }

    // FIXME this may not update
    return StatefulBuilder(builder: (context, setState) => WeekdaysCheckbox(
        onChanged: (weekdays) {
          setState(() {
            weekdays1 = weekdays;
            widget.request.frequency = da.FrequencyDays(weekdays: weekdays);
          });
        },
        weekdays: weekdays1
    ));

  }

  Widget buildFrequencyCountInWeek(BuildContext context) {
    late int value;

    if (widget.request.frequency is da.FrequencyCountInWeek) {
      final frequency = widget.request.frequency as da.FrequencyCountInWeek;
      value = frequency.count;
    } else {
      value = 1;
    }

    final child = StatefulBuilder(builder: (context, setState) {
      return NumberPicker(
        value: value,
        minValue: 1,
        maxValue: 6,
        onChanged: (value0) {
          setState(() {
            value = value0;
            widget.request.frequency = da.FrequencyCountInWeek(count: value);
          });
        },
      );
    },);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        child,
        const Text("天每周")
      ],
    );
  }

  Widget buildFrequncyInterval(BuildContext context) {
    late int interval;

    if (widget.request.frequency is da.FrequencyInterval) {
      final frequency = widget.request.frequency as da.FrequencyInterval;
      interval = frequency.count;
    } else {
      interval = 2;
    }

    final child = StatefulBuilder(builder: (context, setState) {
      return NumberPicker(
        value: interval,
        minValue: 2,
        maxValue: 30,
        onChanged: (value) {
          setState(() {
            interval = value;
            widget.request.frequency = da.FrequencyInterval(count: interval);
          });
        },
      );
    },);

    final textstyle = TextStyle(fontWeight: FontWeight.bold, fontSize: settings["page.daily-attendance.taskedit.taskedit-frequency.frequency-interval.font.size"]);
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("每", style: textstyle,),
        child,
        Text("天", style: textstyle,)
      ],
    );
  }
}

