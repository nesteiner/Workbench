import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/state.dart';
import 'package:frontend/utils.dart';
import 'package:provider/provider.dart';

class TaskDetail extends StatefulWidget {
  Task task;
  int taskgroupIndex;

  TaskDetail({required this.task, required this.taskgroupIndex});

  @override
  TaskDetailState createState() => TaskDetailState();
}

class TaskDetailState extends State<TaskDetail> {
  bool toggleCreate = false;
  bool toggleSearch = false;

  late GlobalState state;
  late void Function(void Function()) setStateToggleCreate;
  late void Function(void Function()) setStateToggleSearch;
  late void Function(void Function()) setStateToggleNote;
  // late void Function(void Function()) setStateChangeTags;


  @override
  Widget build(BuildContext context) {
    // TODO later to look up state
    state = context.read<GlobalState>();


    final center = Center(
      child: Column(
        children: [
          buildInput(context),
          buildState(context),
          buildTime(context),
          buildNote(context),
          buildPriority(context),
          buildTags(context),
          buildEditExpectAndFinishTime(context),
          buildSubTasks(context),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.task.name),),
      body: Padding(padding: settings["widget.task.form.padding"], child: center,)
    );
  }

  Widget buildInput(BuildContext context) {
    final controller = TextEditingController(text: widget.task.name);
    final input = StatefulBuilder(builder: (context, setState) {
      return TextField(
        controller: controller,
        decoration: settings["widget.task.form.input.decoration"],
        style: settings["widget.task.form.input.text-style"],
        onSubmitted: (String? value) async {
          // TODO state to change the name
          if (value?.isNotEmpty ?? false) {
            setState(() {
              controller.text = value!;
            });

            final request = UpdateTaskRequest(id: widget.task.id, name: controller.text);
            await state.updateTask(request, widget.taskgroupIndex);
          }
        },
      );
    });

    return Container(
      width: double.infinity,
      margin: settings["widget.task.form.input.margin"],
      child: input,
    );
  }

  Widget buildState(BuildContext context) {
    final rowStateLeft = SizedBox(
      width: settings["widget.task.form.left.width"],
      height: settings["widget.task.form.item.height"],
      child: const Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_box_outlined, color: Color.fromRGBO(0, 0, 0, 0.5),),
          SizedBox(width: 8,),
          Text("状态", style: TextStyle(color: Color.fromRGBO(140, 140, 140, 1)))
        ],
      ),
    );


    final rowStateRight = Container(
      decoration: BoxDecoration(
          color: widget.task.isdone ? const Color.fromRGBO(21, 173, 49, 0.1) : const Color.fromRGBO(38, 38, 38, 0.05),
          borderRadius: settings["widget.task.form.state.border-radius"]
      ),

      padding: settings["widget.task.form.state.padding"],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: widget.task.isdone,
            activeColor: HexColor.fromHex("#a8d08e"),
            onChanged: (bool? value) async {
              if (value != null) {
                setState(() {
                  widget.task.isdone = value;
                });

                final request = UpdateTaskRequest(id: widget.task.id, isdone: value);
                await state.updateTask(request, widget.taskgroupIndex);
              }
            },
          ),

          widget.task.isdone ? Text("已完成", style: TextStyle(color: HexColor.fromHex("#038a24")),) : Text("未完成", style: TextStyle(color: HexColor.fromHex("#595959"),))
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        rowStateLeft,
        rowStateRight
      ],
    );
  }

  Widget buildTime(BuildContext context) {
    final rowTimeLeft = SizedBox(
      width: settings["widget.task.form.left.width"],
      height: settings["widget.task.form.item.height"],
      child: const Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, color: Color.fromRGBO(0, 0, 0, 0.5),),
          SizedBox(width: 8,),
          Text("时间", style: TextStyle(color: Color.fromRGBO(140, 140, 140, 1)))
        ],
      ),
    );

    final flagDeadline = widget.task.deadline != null;
    late Text deadlineText;

    if (flagDeadline) {
      deadlineText = Text(widget.task.deadline!.toIso8601String(), style: const TextStyle(color: Colors.blue),);
    } else {
      deadlineText = const Text("设置截止时间", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),);
    }

    Widget deadlinePart = TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero
      ),
      onPressed: () async {
        final now = DateTime.now();
        final date = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 30)));
        if (date != null) {
          final timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());

          if (timeOfDay != null) {
            final datetime = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);

            setState(() {
              widget.task.deadline = datetime;
            });
          }
        }
      },
      child: deadlineText
    );

    final flagNotifyTime = widget.task.notifyTime != null;
    late Widget notifyTimePart;

    onPressedNotifyTime() async {
      final now = DateTime.now();
      final date = await showDatePicker(context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 30)));
      if (date != null) {
        final timeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.now());

        if (timeOfDay != null) {
          final datetime = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);

          setState(() {
            widget.task.notifyTime = datetime;
          });
        }
      }
    }

    if (flagNotifyTime) {
      notifyTimePart = TextButton(
        onPressed: onPressedNotifyTime,
        child: Text(widget.task.notifyTime!.toIso8601String()),
      );
    } else {
      notifyTimePart = IconButton(
        onPressed: onPressedNotifyTime,
        icon: const Icon(Icons.alarm, color: Color.fromRGBO(0, 0, 0, 0.5),),
      );
    }


    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        rowTimeLeft,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            deadlinePart,
            const SizedBox(width: 16,),
            notifyTimePart
          ],
        )
      ],
    );
  }

  Widget buildNote(BuildContext context) {
    bool toggled = false;
    bool flag = widget.task.note?.isNotEmpty ?? false;

    final noteController = TextEditingController(text: widget.task.note ?? "");

    final rowNoteLeft = SizedBox(
      width: settings["widget.task.form.left.width"],
      height: settings["widget.task.form.item.height"],
      child: const Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, color: Color.fromRGBO(0, 0, 0, 0.5),),
          SizedBox(width: 8,),
          Text("备注", style: TextStyle(color: Color.fromRGBO(140, 140, 140, 1)))
        ],
      ),
    );

    final width = MediaQuery.of(context).size.width;
    final textfield = Container(
      width: width * 0.8,
      // TODO later to check this
      margin: settings["widget.task.form.note.edit.margin"],
      child: TextField(
        controller: noteController,
        minLines: 5,
        maxLines: 10,
        decoration: settings["widget.task.form.note.edit.input.decoration"],
      ),
    );

    final actions = Row(
      children: [
        // Expanded(child: Container()),
        Row(children: [
          ElevatedButton(
              onPressed: () => setStateToggleNote(() => toggled = false),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("取消", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),)
          ),

          const SizedBox(width: 4,),
          ElevatedButton(
              onPressed: () async {
                // TODO use state to save note
                setStateToggleNote(() {
                  widget.task.note = noteController.text;
                  flag = widget.task.note?.isNotEmpty ?? false;
                  toggled = false;
                });

                final request = UpdateTaskRequest(id: widget.task.id, note: noteController.text);
                await state.updateTask(request, widget.taskgroupIndex);
              },
              child: const Text("保存", style: TextStyle(color: Colors.white),)
          )
        ],)
      ],
    );

    final noteedit = StatefulBuilder(builder: (context, setState) {
      setStateToggleNote = setState;
      late Widget noteentry;

      if (flag) {
        noteentry = Container(
          color: Colors.yellow,
          padding: settings["page.taskdetail.note.padding"],
          child: Text(widget.task.note!, overflow: TextOverflow.ellipsis,),
        );
      } else {
        noteentry = const Text("待添加", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),);
      }

      if (!toggled) {
        return GestureDetector(
          onTap: () {
            setState(() {
              toggled = true;
            });
          },

          child: SizedBox(
            // height: settings["widget.task.form.item.height"],
            child: Center(
              child: Column(
               children: [
                 SizedBox(height: 8,),
                 noteentry,
               ],
              )
            )
          ),
        );
      } else {
        // TODO later to satisfy android platform
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            textfield,

            SizedBox(height: 4,),
            actions
          ],
        );
      }
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        rowNoteLeft,
        noteedit
      ],
    );

  }

  Widget buildPriority(BuildContext context) {
    final rowPriorityLeft = SizedBox(
      width: settings["widget.task.form.left.width"],
      height: settings["widget.task.form.item.height"],
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.flag_outlined, color: Color.fromRGBO(0, 0, 0, 0.5),),
          SizedBox(width: 8,),
          Text("优先级", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),)
        ],
      ),
    );

    final priorities = StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        height: settings["widget.task.form.item.height"],
        child: Center(
          child: PopupMenuButton<int>(
            child: buildPriorityWidget(widget.task.priority),
            onSelected: (int value) async {
              widget.task.priority = value;
              final request = UpdateTaskRequest(id: widget.task.id, priority: value);
              await state.updateTask(request, widget.taskgroupIndex);

              setState(() {

              });

            },
            itemBuilder: (_) => [
              PopupMenuItem(child: buildPriorityWidget(LOW_PRIORITY), value: LOW_PRIORITY,),
              PopupMenuItem(child: buildPriorityWidget(NORMAL_PRIORITY), value: NORMAL_PRIORITY,),
              PopupMenuItem(child: buildPriorityWidget(HIGH_PRIORITY), value: HIGH_PRIORITY,)
            ],
          ),
        ),
      );
    });
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        rowPriorityLeft,
        priorities
      ],
    );
  }

  Widget buildTags(BuildContext context) {
    final rowTagsLeft = SizedBox(
      width: settings["widget.task.form.left.width"],
      height: settings["widget.task.form.item.height"],
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.tag, color: Color.fromRGBO(0, 0, 0, 0.5),),
          SizedBox(width: 8,),
          Text("标签", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),)
        ],
      ),
    );


    final tasktags = Selector<GlobalState, String>(
      selector: (_, state) => (widget.task.tags ?? []).map((e) => "${e.id}-${e.name}").join(","),
      builder: (_, value, child) => Wrap(
        children: (widget.task.tags ?? []).map((e) => buildTagWidget(context, e)).toList(),
      )
    );

    final popupbutton = Selector<GlobalState, String>(
      selector: (_, state) => (state.currentTags ?? []).map((e) => "${e.id}-${e.name}").join(","),
      builder: (_, value, child) => PopupMenuButton<Tag>(
        child: const Icon(Icons.add_circle_outline, color: Color.fromRGBO(0, 0, 0, 0.3),),
        itemBuilder: (context) => [
          PopupMenuItem(child: buildTagSearchAndCreate(context), enabled: false,),
          ...((state.currentTags ?? []).where((element) => ! (widget.task.tags ?? []).contains(element)))
              .map((e) => PopupMenuItem(child: buildTagInMenu(context, e), value: e))
              .toList()
        ],

        onSelected: (tag) async {
          await state.insertTagExists(tag, widget.task);
        },
      ),
    );

    return Row(
      children: [
        rowTagsLeft,

        tasktags,

        popupbutton
      ],
    );



  }

  Widget buildSubTasks(BuildContext context) {
    final flag = widget.task.subtasks?.isNotEmpty ?? false;
    if (flag) {
      final taskcount = widget.task.subtasks!.length;
      final taskfinishcount = widget.task.subtasks!.where((element) => element.isdone).length;

      final rowSubTasksLeft = SizedBox(
        width: settings["widget.task.form.left.width"],
        height: settings["widget.task.form.item.height"],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, color: Color.fromRGBO(0, 0, 0, 0.5),),
            const SizedBox(width: 8,),
            const Text("子任务", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
            const Text(" - "),
            Text("$taskfinishcount/$taskcount", style: const TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),)
          ],
        ),
      );

      final children = widget.task.subtasks!.map<Widget>((e) => buildSubTaskWidget(context, e)).toList();
      children.add(buildSubTaskAdd(context));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowSubTasksLeft,
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.3)),
              borderRadius: settings["widget.task.subtask.border-radius"]
            ),
            
            child: Column(
              children: children
            ),
          )
        ],
      );
    } else {
      final rowSubTasksLeft = SizedBox(
        width: settings["widget.task.form.left.width"],
        height: settings["widget.task.form.item.height"],
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, color: Color.fromRGBO(0, 0, 0, 0.5),),
            SizedBox(width: 8,),
            Text("子任务", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),),
            Text(" - "),
          ],
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowSubTasksLeft,
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.3)),
                borderRadius: settings["widget.task.subtask.border-radius"]
            ),

            child: buildSubTaskAdd(context)
          )
          
        ],
      );
    }
  }

  Widget buildPriorityWidget(int value) {
    if (value == LOW_PRIORITY) {
      return Wrap(
        children: [
          Container(
            padding: settings["widget.task.form.priority.padding"],
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.3), width: 0.3),
              borderRadius: settings["widget.task.form.priority.border-radius"]
            ),
            child: const Text("较低", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.3)),),
          )
        ],
      );
    } else if (value == NORMAL_PRIORITY) {
      return Wrap(
        children: [
          Container(
            padding: settings["widget.task.form.priority.padding"],
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 0.3),
                borderRadius: settings["widget.task.form.priority.border-radius"]
            ),
            child: const Text("普通", style: TextStyle(color: Colors.blue),),
          )
        ],
      );
    } else if (value == HIGH_PRIORITY) {
      return Wrap(
        children: [
          Container(
            padding: settings["widget.task.form.priority.padding"],
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red, width: 0.3),
                borderRadius: settings["widget.task.form.priority.border-radius"]
            ),
            child: const Text("紧集", style: TextStyle(color: Colors.red),),
          )
        ],
      );
    } else {
      throw Exception("no such value of priority");
    }
  }

  Widget buildTagWidget(BuildContext context, Tag tag) {
    final textColor = tag.color.withOpacity(1);
    return Wrap(
      children: [
        Container(
          margin: settings["widget.task.form.tag.margin"],
          padding: settings["widget.task.form.tag.padding"],
          decoration: BoxDecoration(
              color: tag.color,
              borderRadius: settings["widget.task.form.tag.border-radius"]
          ),

          child: Text(tag.name, style: TextStyle(color: textColor),),
        )
      ],
    );
  }

  Widget buildTagSearchAndCreate(BuildContext context) {
    final controller = TextEditingController();
    final disabled = ValueNotifier(true);

    final input = SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        decoration: settings["widget.task.form.search-create.input.decoration"],
        onChanged: (String? value) {
          if (value?.isEmpty ?? true) {
            disabled.value = true;
          } else {
            disabled.value = false;
          }
        },
      ),
    );

    final toggleCreateButton = ListenableBuilder(
        listenable: disabled,
        builder: (context, child) => IconButton(
          onPressed: disabled.value ? null : () async {
            final request = PostTagRequest(name: controller.text , parentid: state.currentProject!.id, color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.3));
            await state.insertTagNotExists(request, widget.task);
            navigatorKey.currentState?.pop();
          },

          icon: const Icon(Icons.add_circle_outline, color: Color.fromRGBO(0, 0, 0, 0.5),),
        )
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [input, toggleCreateButton],
    );
  }

  Widget buildSubTaskWidget(BuildContext context, SubTask subtask) {
    TextEditingController controller = TextEditingController(text: subtask.name);

    final checkbox = StatefulBuilder(builder: (context, setState) {
      return Checkbox(
        value: subtask.isdone,
        onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              subtask.isdone = value;
            });
          }
        },
      );
    },);

    InputDecoration? decoration;

    if (subtask.isdone) {
      decoration = const InputDecoration(
        border: InputBorder.none
      );
    }

    final textfield = TextField(
      controller: controller,
      decoration: decoration,
    );

    final taskcontent = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: textfield,
      ),
    );

    final deleteButton = IconButton(
      onPressed: () {
        // TODO later to delete this subtask using state
      },

      icon: const Icon(Icons.delete_forever_outlined, color: Colors.red,),
    );

    final row = Row(
      children: [
        checkbox,
        taskcontent,
        deleteButton
      ],
    );

    return Container(
      padding: const EdgeInsets.only(top: 2, right: 12, bottom: 2, left: 16),
      child: row,
    );
  }

  Widget buildSubTaskAdd(BuildContext context) {
    bool isdone = false;
    bool toggled = false;
    TextEditingController controller = TextEditingController();

    return StatefulBuilder(builder: (context, setState) {
      final checkbox = Checkbox(
        value: isdone,
        onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              isdone = value;
            });
          }
        },
      );

      final saveButton = ElevatedButton(
        onPressed: controller.text.isEmpty ? null : () {
          // TODO later to add it

          setState(() {
            toggled = false;
          });
        },

        style: ElevatedButton.styleFrom(
            backgroundColor: controller.text.isEmpty ? Colors.grey : Colors.blue
        ),

        child: const Text("保存", style: TextStyle(color: Colors.white),),
      );


      final textfield = TextField(
        controller: controller,
        onChanged: (String? value) {
          // TODO later maybe I should make a new StatefulBuilder
          setState(() {});
        },

        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(7),
          border: OutlineInputBorder(),
          hintText: "输入任务内容..."
        ),
      );

      final buttons = [
        ElevatedButton(
          onPressed: () {
            setState(() {
              toggled = false;
            });
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white
          ),

          child: const Text("取消", style: TextStyle(color: Colors.blue),),
        ),

        const SizedBox(width: 8,),

        saveButton
      ];

      final addbutton = TextButton(
        style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 2)),
        onPressed: () {
          setState(() {
            toggled = true;
          });
        },

        child: const Row(children: [Icon(Icons.add, color: Colors.blue,), Text("添加子任务", style: TextStyle(color: Colors.blue),)],),
      );

      late Widget child;
      if (toggled) {

        final input = Row(
          children: [
            checkbox,
            Expanded(child: textfield)
          ],
        );

        child = Column(
          children: [
            input,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buttons,
            ),

            addbutton
          ],
        );

      } else {
        child = addbutton;
      }

      return Container(
        padding: const EdgeInsets.only(top: 2, right: 12, bottom: 2, left: 16),
        child: child
      );
    },);
  }

  Widget buildTagInMenu(BuildContext context, Tag tag) {
     return Container(
       width: settings["widget.task.form.menu.tag.width"],
       height: settings["widget.task.form.menu.tag.height"],
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
           mainAxisSize: MainAxisSize.max,
           children: [
             Container(
               width: 8,
               height: 8,
               margin: const EdgeInsets.only(right: 8),
               decoration: BoxDecoration(color: tag.color, borderRadius: const BorderRadius.all(Radius.circular(4))),
             ),

             Text(tag.name, overflow: TextOverflow.ellipsis,)
           ],
        ),
     );
  }

  Widget buildTagCreate(BuildContext context) {
    final controller = TextEditingController();
    late void Function(void Function()) setStateInput;

    final head = Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: Color.fromRGBO(0, 0, 0, 0.3))
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },

            icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromRGBO(0, 0, 0, 0.5),),
          ),

          const Text("新建标签", style: TextStyle(fontWeight: FontWeight.bold),),

          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },

            icon: const Icon(Icons.close, color: Color.fromRGBO(0, 0, 0, 0.5),),
          )
        ],
      ),
    );

    final input = TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: "标签名称",
        border: OutlineInputBorder()
      ),

      onChanged: (String? value) {
        setStateInput(() {});
      },
    );

    final colorsChildren = [Colors.blue, Colors.green, const Color.fromRGBO(0, 156, 149, 1), Colors.purple, Colors.orange, Colors.red]
        .map((e) {
          return ListTile(
            title: Text(e.toString()),
            leading: Radio<Color>(
              groupValue: Colors.white,
              value: e,
              onChanged: (Color? value) {
                // TODO later to set color
              },
            ),
          );
    }).toList();

    final colors = Column(
      children: colorsChildren,
    );

    return StatefulBuilder(builder: (context, setState) {
      setStateInput = setState;
      return Column(
        children: [
          head,
          input,
          colors,
          ElevatedButton(
             onPressed: controller.text.isEmpty ? null : () {
               // TODO later to add

               Navigator.of(context).pop();
             },

             child: const Text("创建"),
           )
        ],
      );
    });
  }

  Widget buildEditExpectAndFinishTime(BuildContext context) {
    final left = Container(
      width: settings["widget.task.form.left.width"],
      height: settings["widget.task.form.item.height"],
      // 微调
      padding: const EdgeInsets.only(left: 4),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Ast/Est", style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.5)),)
        ],
      ),
    );

    final right = Row(
      children: [
        Selector<GlobalState, int>(
          selector: (_, state) => widget.task.finishTime,
          builder: (_, value, child) => Container(
            padding: settings["page.taskdetail.edit.expect-finish.text-container.padding"],
            width: settings["page.taskdetail.edit.expect-finish.text-container.width"],
            decoration: settings["page.taskdetail.edit.expect-finish.text-container.decoration"],
            child: Text(value.toString()),
          ),
        ),

        Container(
          margin: settings["page.taskdetail.edit.expect-finish.slash.margin"],
          child: Text("/", style: settings["page.taskdetail.edit.expect-finish.slash.text-style"],),
        ),

        Selector<GlobalState, int>(
          selector: (_, state) => widget.task.expectTime,
          builder: (_, value, child) => Container(
            padding: settings["page.taskdetail.edit.expect-finish.text-container.padding"],
            width: settings["page.taskdetail.edit.expect-finish.text-container.width"],
            margin: settings["page.taskdetail.edit.expect-finish.text-container.last.margin"],
            decoration: settings["page.taskdetail.edit.expect-finish.text-container.decoration"],
            child: Text(value.toString()),
          ),
        ),

        Container(
          padding: settings["page.taskdetail.edit.expect-finish.button.padding"],
          margin: settings["page.taskdetail.edit.expect-finish.button.margin"],
          decoration: settings["page.taskdetail.edit.expect-finish.button.decoration"],
          child: GestureDetector(
            onTap: () async {
              final request = UpdateTaskRequest(id: widget.task.id, expectTime: widget.task.expectTime + 1);
              widget.task.expectTime += 1;
              await state.updateTask(request, widget.taskgroupIndex);
            },

            child: Center(
              child: const Icon(Icons.arrow_drop_up),
            ),
          ),
        ),

        Container(
          padding: settings["page.taskdetail.edit.expect-finish.button.padding"],
          margin: settings["page.taskdetail.edit.expect-finish.button.margin"],
          decoration: settings["page.taskdetail.edit.expect-finish.button.decoration"],
          child: GestureDetector(
            onTap: () async {
              if (widget.task.expectTime > 1) {

                final request = UpdateTaskRequest(id: widget.task.id,
                    expectTime: widget.task.expectTime - 1);

                widget.task.expectTime -= 1;
                await state.updateTask(request, widget.taskgroupIndex);
              }
            },

            child: Center(
              child: const Icon(Icons.arrow_drop_down),
            ),
          ),
        )
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        left,
        right
      ],
    );
  }
}