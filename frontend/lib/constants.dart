import 'package:flutter/material.dart';
import 'package:frontend/utils.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/io.dart';

Map<String, dynamic> settings = {
  "page.login.body.padding": const EdgeInsets.symmetric(vertical: 10.0),
  "page.login.body.margin-top": 50.0,
  "page.login.button.height": 50.0,
  "page.taskproject-add.content.padding": const EdgeInsets.symmetric(horizontal: 8),
  "page.taskproject-add.item.margin": const EdgeInsets.symmetric(vertical: 4),

  "page.taskgroup-board.appbar.font.color": const Color.fromRGBO(0, 0, 0, 0.5),
  "page.taskgroup-board.appbar.menu.padding": const EdgeInsets.only(left: 12),
  "page.taskgroup-board.appbar.menu.icon.margin": 10.0,
  "page.taskgroup-board.appbar.menu.height": 36.0,
  "page.taskgroup-board.appbar.menu.width": 192.0,
  "page.taskgroup-board.appbar.dialog.delete.icon.margin": 20.0,
  "page.taskgroup-board.appbar.dialog.delete.title.font.style": const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22),
  "page.taskgroup-board.appbar.dialog.delete.content.font.style": const TextStyle(
      color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 18),
  "page.taskgroup-board.appbar.dialog.delete.cancel.font.style": const TextStyle(
      color: Colors.blue),
  "page.taskgroup-board.appbar.dialog.delete.confirm.font.style": const TextStyle(
      color: Colors.white),
  "page.taskgroup-board.appbar.dialog.edit.width": 300.0,
  "page.taskgroup-board.appbar.dialog.edit.padding": const EdgeInsets.all(16),
  "page.taskgroup-board.appbar.dialog.edit.title.input-decoration": (String labelText) => InputDecoration(
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    labelText: labelText
  ),

  "page.taskgroup-board.appbar.dialog.edit.profile.input-decoration": (String labelText) => InputDecoration(
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      hintText: "请描述项目概述",
      labelText: labelText
  ),

  "page.taskdetail.edit.expect-finish.text-container.padding": const EdgeInsets
      .all(10),
  "page.taskdetail.edit.expect-finish.text-container.width": 75.0,
  "page.taskdetail.edit.expect-finish.text-container.decoration": const BoxDecoration(
      color: Color.fromRGBO(239, 239, 239, 1),
      borderRadius: BorderRadius.all(Radius.circular(4))
  ),
  "page.taskdetail.edit.expect-finish.slash.margin": const EdgeInsets.symmetric(
      horizontal: 6),
  "page.taskdetail.edit.expect-finish.slash.text-style": const TextStyle(
      color: Color.fromRGBO(187, 187, 187, 1)),
  "page.taskdetail.edit.expect-finish.text-container.last.margin": const EdgeInsets
      .only(right: 10),

  "page.taskdetail.edit.expect-finish.button.padding": const EdgeInsets
      .symmetric(vertical: 8, horizontal: 12),
  "page.taskdetail.edit.expect-finish.button.margin": const EdgeInsets
      .symmetric(horizontal: 2),
  "page.taskdetail.edit.expect-finish.button.decoration": BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      color: Colors.white,
      border: Border.all(color: Color.fromRGBO(223, 223, 223, 1), width: 1)
  ),

  "page.taskdetail.note.padding": const EdgeInsets.all(4),
  "page.taskdetail.note.max-height": 600.0,
  "page.taskdetail.note.max-width": 600.0,
  "page.taskdetail.note.min-height": 400.0,
  "page.taskdetail.note.min-width": 400.0,
  "page.taskdetail.subtask.padding": const EdgeInsets.only(
      top: 2, right: 24, bottom: 2, left: 16),
  "widget.image-uploader.border-radius": const BorderRadius.all(
      Radius.circular(8)),
  "widget.image-uploader.width": 266.0,
  "widget.image-uploader.height": 106.39,

  "widget.task.form.padding": const EdgeInsets.symmetric(horizontal: 16),
  "widget.task.form.input.decoration": InputDecoration(
    contentPadding: const EdgeInsets.only(left: 4),
    border: InputBorder.none,
  ),

  "widget.task.form.input.text-style": TextStyle(
      fontWeight: FontWeight.bold, fontSize: 24),
  "widget.task.form.input.margin": const EdgeInsets.symmetric(vertical: 20),
  "widget.task.form.note.edit.margin": const EdgeInsets.only(top: 8),
  "widget.task.form.note.edit.input.decoration": InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(
        width: 1,
        color: Color.fromRGBO(0, 0, 0, 0.3),
      ),
    ),
  ),

  "widget.task.form.priority.padding": const EdgeInsets.all(4),
  "widget.task.form.tag.margin": const EdgeInsets.symmetric(
      horizontal: 4, vertical: 2),
  "widget.task.form.tag.padding": const EdgeInsets.symmetric(
      horizontal: 8, vertical: 4),
  "widget.task.form.tag.close.margin-right": 4.0,
  "widget.task.form.tag.search-create.input.decoration": InputDecoration(
    contentPadding: const EdgeInsets.only(left: 8),
    border: OutlineInputBorder(),

    hintText: "添加标签",
  ),
  "widget.task.content.padding": const EdgeInsets.only(
      top: 14, right: 16, bottom: 14, left: 0),
  "widget.task.attach.padding": const EdgeInsets.only(bottom: 14),
  "widget.task.attach.font-size": 10.0,
  "widget.task.attach.height": 20.0,
  "widget.task.left-line.width": 3.0,
  "widget.task.left-line.hover.width": 6.0,
  "widget.task.left-line.border-radius": const BorderRadius.only(
      topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
  "widget.task.width": 272.0,
  "widget.task.height": 48.0,
  "widget.task.border-radius": const BorderRadius.all(Radius.circular(4)),
  "widget.task.box-shadow": BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color.fromRGBO(0, 0, 0, 0.1)
  ),

  "widget.task.margin": const EdgeInsets.only(bottom: 8),

  "widget.task.form.left.width": 140.0,
  "widget.task.form.state.border-radius": const BorderRadius.all(
      Radius.circular(4)),
  "widget.task.form.item.height": 36.0,
  "widget.task.form.state.padding": const EdgeInsets.only(right: 8),
  "widget.task.form.menu.tag.width": 241.0,
  "widget.task.form.menu.tag.height": 40.0,
  "widget.task.form.priority.border-radius": const BorderRadius.all(
      Radius.circular(4)),
  "widget.task.form.tag.border-radius": const BorderRadius.all(
      Radius.circular(8)),


  "widget.task.subtask.border-radius": const BorderRadius.all(
      Radius.circular(4)),
  "widget.taskgroup.padding": const EdgeInsets.symmetric(horizontal: 12),
  "widget.taskgroup.task-add.margin": const EdgeInsets.only(bottom: 8),
  "widget.taskgroup.width": 296.0,
  "widget.taskgroup.task-add.height": 30.0,
  "widget.taskgroup.task-add.box-shadow": const BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color.fromRGBO(0, 0, 0, 0.1)

  ),

  "widget.taskgroup.task-add.expand.padding": const EdgeInsets.only(
      top: 12, right: 12, bottom: 16, left: 12),
  "widget.taskgroup.task-add.expand.margin": const EdgeInsets.only(bottom: 8),
  "widget.taskgroup.task-add.expand.decoration": BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.1)
        )
      ]

  ),

  "widget.taskproject.min-width": 140.0,
  "widget.taskproject.max-width": 250.0,
  "widget.taskproject.border-radius": const BorderRadius.all(
      Radius.circular(12.0)),
  "widget.taskproject.background-color": Colors.white,
  "widget.taskproject.box-shadow": BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 5,
      color: Color.fromRGBO(38, 38, 38, 0.1)
  ),


  "widget.taskproject.footer.padding": const EdgeInsets.only(
      top: 10, right: 12, bottom: 10, left: 16),
  "widget.taskproject.footer.border-radius": const BorderRadius.only(
      bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)),
  "widget.taskproject.footer.height": 44.0,
  "widget.taskproject.margin": const EdgeInsets.only(right: 16, bottom: 16),
  "widget.taskproject.width": 208.5,
  "widget.taskproject.thumbnail.border-radius.desktop": const BorderRadius.only(
      topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
  "widget.taskproject.thumbnail.border-radius.mobile": const BorderRadius.all(
      Radius.circular(12.0)),

  "widget.taskproject.add.icon.padding": const EdgeInsets.all(16.0),
  "widget.taskproject.add.border-radius": const BorderRadius.all(
      Radius.circular(12.0)),
  "widget.taskproject.add.box-shadow": const BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 5,
      color: Color.fromRGBO(38, 38, 38, 0.1)
  ),
  "widget.taskproject.add.icon.size": 20.0,
  "widget.taskproject.add.color": const Color.fromRGBO(0, 0, 0, 0.7),
  "widget.taskproject.add.create.padding": const EdgeInsets.only(
      top: 10, right: 12, bottom: 10, left: 16),
  "widget.taskproject.add.background-color": HexColor.fromHex("#f7f7f7"),
  "widget.taskproject.add.margin": const EdgeInsets.only(right: 16, bottom: 16),

  "widget.taskproject.thumbnail.max-height": 100.0,
  "widget.taskproject.thumbnail.size.mobile": 40.0,
  "widget.taskproject.thumbnail.text-style": const TextStyle(fontSize: 24),
  "widget.taskproject.thumbnail.footer.text-style": const TextStyle(fontSize: 16, color: Color.fromRGBO(0, 0, 0, 0.3)),
  "widget.taskproject.padding": const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),

  "page.taskgroup-board.width": 296.0,
  "page.taskgroup-board.items.padding": const EdgeInsets.symmetric(
      horizontal: 12),
  "page.taskgroup-board.add.font.color": HexColor.fromHex("#8c8c8c"),
  "page.taskgroup-board.add.icon.margin": const EdgeInsets.only(
      left: 4, right: 8),

  "widget.taskgroup.head.height": 40.0,

  "widget.image-uploader.buttons.margin": 10.0,

  "widget.pomodoro.counter.width.desktop": 480.0,
  "widget.pomodoro.counter.decoration": const BoxDecoration(
      color: Color.fromRGBO(255, 255, 255, 0.1)),
  "widget.pomodoro.counter.focus.text-style": const TextStyle(
      color: Colors.white),
  "widget.pomodoro.counter.padding": const EdgeInsets.only(top: 20, bottom: 30),
  "widget.pomodoro.counter.margin": const EdgeInsets.only(top: 40, bottom: 20),
  "widget.pomodoro.counter.time-text.style": const TextStyle(
      fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold),
  "widget.pomodoro.counter.button.text-style": const TextStyle(fontSize: 22,
      color: Color.fromRGBO(186, 73, 73, 1),
      fontWeight: FontWeight.bold),
  "widget.pomodoro.counter.button.decoration": const BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(4))),
  "widget.pomodoro.counter.button.width": 200.0,
  "widget.pomodoro.counter.button.height": 55.0,
  "widget.pomodoro.counter.button.margin": const EdgeInsets.only(top: 20),
  "widget.pomodoro.counter.button.padding": const EdgeInsets.symmetric(
      horizontal: 12),

  "widget.pomodoro.taskcard.count.text-style": const TextStyle(
      color: Colors.grey),

  "widget.pomodoro.taskcard.image.size": 22.0,
  "widget.pomodoro.padding": const EdgeInsets.symmetric(horizontal: 8.0),
  // please edit this two item together
  "widget.pomodoro.taskcard.padding": const EdgeInsets.only(
      top: 18, bottom: 18, left: 14, right: 14),
  "widget.pomodoro.taskcard.select.margin": const EdgeInsets.only(left: 14),
  // please edit this two items together
  "widget.pomodoro.taskcard.margin": const EdgeInsets.only(bottom: 8),
  "widget.pomodoro.taskcard.padding.bottom": 8.0,

  "widget.pomodoro.taskcard.selected.width": 2.0,
  "widget.pomodoro.pomodoro-board.taskgroup-menu.width.desktop": 120.0,
  "widget.pomodoro.pomodoro-board.red": const Color.fromRGBO(186, 73, 73, 1),
  "widget.pomodoro.pomodoro-board.green": const Color.fromRGBO(56, 133, 138, 1),
  "widget.pomodoro.pomodoro-board.blue": const Color.fromRGBO(57, 112, 151, 1),
  "widget.pomodoro.pomodoro-board.select.padding": const EdgeInsets.symmetric(
      horizontal: 8, vertical: 2),
  "widget.pomodoro.pomodoro-board.select.decoration": BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      border: Border.all(color: Colors.white, width: 2)
  ),

  "widget.pomodoro.pomodoro-board.counter.margin-bottom": 20.0,
  "widget.pomodoro.pomodoro-board.taskheader.decoration": const BoxDecoration(
      border: Border(bottom: BorderSide(
          width: 2, color: Color.fromRGBO(255, 255, 255, 0.6)))
  ),

  "widget.pomodoro.pomodoro-board.taskheader.padding": const EdgeInsets.only(
      bottom: 14, left: 10, right: 10),
  "widget.pomodoro.pomodoro-board.taskheader.padding.icon-text": 8.0,
  "common.svg.size": 20.0,
  "common.unit.size": 8.0,

  "widget.daily-attendance.task.icon.size": 48.0,
  "widget.daily-attendance.task.icon.border-radius": const BorderRadius.all(
      Radius.circular(18)),
  "widget.daily-attendance.task.padding": const EdgeInsets.all(10),
  "widget.daily-attendance.task.icon.margin": 8.0,
  "widget.daily-attendance.switcher.icon.size": 70.0,
  "widget.daily-attendance.switcher.icon.border-radius": const BorderRadius.all(
      Radius.circular(35)),
  "widget.daily-attendance.switcher.slot.width": 210.0,
  "widget.daily-attendance.switcher.slot.background-color": const Color
      .fromRGBO(0, 0, 0, 0.1),


  "page.daily-attendance.taskrecording.background.default-color": HexColor
      .fromHex("#eccc68"),
  "page.daily-attendance.taskrecording.background.icon.size": 200.0,
  "page.daily-attendance.taskrecording.margin.0": 24.0,
  "page.daily-attendance.taskrecording.margin.1": 4.0,
  "page.daily-attendance.taskrecording.margin.2": 32.0,
  "page.daily-attendance.taskrecording.margin.3": 16.0,
  "page.daily-attendance.taskrecording.font.color": Colors.white,
  "page.daily-attendance.taskrecording.font.title.size": 38.0,
  "page.daily-attendance.taskrecording.font.encouragement.size": 18.0,
  "page.daily-attendance.taskrecording.font.days.style.0": const TextStyle(
      fontSize: 20),
  "page.daily-attendance.taskrecording.font.days.style.1": const TextStyle(
      color: Color.fromRGBO(0, 0, 0, 0.5), fontSize: 10),
  "page.daily-attendance.taskrecoring.menu.width": 156.0,

  "page.daily-attendance.taskedit.item.padding": const EdgeInsets.all(10),
  "page.daily-attendance.taskedit.item.margin": 12.0,
  "page.daily-attendance.taskedit.image-pick-upload.item.size": 100.0,
  "page.daily-attendance.taskedit.image-pick-upload.item.decoration": BoxDecoration(
      border: Border.all(color: Colors.grey, width: 2),
      shape: BoxShape.circle
  ),
  "page.daily-attendance.taskedit.taskedit-frequency.frequency-interval.font.size": 32.0,
  "page.daily-attendance.taskedit.image-pick-upload.item.icon.size": 40.0,
  "page.daily-attendance.taskedit.image-pick-upload.item.margin": 8.0,

  // width, height
  "page.daily-attendance.color-select.grid.aspect-ratio": 0.5,
  "page.daily-attendance.taskedit.wrapper.decoration": const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.1)
        ),
      ]
  ),
  "page.daily-attendance.taskedit.wrapper.margin": const EdgeInsets.all(8),
  "page.daily-attendance.taskedit.wrapper.padding": const EdgeInsets.all(12),
  "page.daily-attendance.taskedit.tabbody.max-height": 200.0,
  "page.daily-attendance.taskedit.tabbody.min-height": 40.0,
  "page.daily-attendance.taskedit.edit-name-icon.margin-bottom": 8.0,
  "page.daily-attendance.taskedit.edit-goal.margin-bottom": 8.0,
  "page.daily-attendance.taskedit.edit-goal.textfield.width.0": 40.0,
  "page.daily-attendance.taskedit.edit-goal.textfield.width.1": 100.0,
  "page.daily-attendance.taskedit.edit-group.item.padding": const EdgeInsets
      .symmetric(horizontal: 24.0, vertical: 4.0),
  "page.daily-attendance.taskedit.edit-group.title.margin-bottom": 8.0,
  "page.daily-attendance.taskedit.edit-group.item.margin": const EdgeInsets
      .only(right: 4.0),
  "page.daily-attendance.taskedit.edit-group.item.border-radius": BorderRadius
      .circular(4.0),

  "page.daily-attendance.taskedit.edit-notify-times.title.margin-bottom": 8.0,
  "page.daily-attendance.taskedit.edit-notify-times.item.padding": const EdgeInsets
      .symmetric(horizontal: 16.0, vertical: 4.0),
  "page.daily-attendance.taskedit.edit-notify-times.item.margin": const EdgeInsets
      .only(right: 4),
  "page.daily-attendance.taskedit.edit-notify-times.item.decoration": BoxDecoration(
      borderRadius: BorderRadius.circular(4.0),
      color: const Color.fromRGBO(0, 0, 0, 0.1)
  ),

  "page.daily-attendance.taskedit.edit-encouragement.title.margin-bottom": 8.0,

  "widget.daily-attendance.checkbox.margin": const EdgeInsets.symmetric(
      horizontal: 8),
  "widget.daily-attendance.checkbox.padding": const EdgeInsets.all(8.0),
  "widget.daily-attendance.checkbox.wrapper.padding": const EdgeInsets.all(8.0),
  "widget.daily-attendance.switcher.width": 200.0,
  "widget.daily-attendance.switcher.height": 60.0,
  "widget.daily-attendance.switcher.button.width": 60.0,
  "widget.daily-attendance.switcher.button.height": 60.0,
  "widget.daily-attendance.switcher.button.start-left": 0.0,
  "widget.daily-attendance.date-select-panel.item.inner.margin-bottom": 12.0,
  "widget.daily-attendance.date-select-panel.item.day.padding": const EdgeInsets
      .all(8.0),

  "page.daily-attendance.task-page.appbar.font-size": 24.0,
  "page.daily-attendance.task-page.expansion-panel.padding": const EdgeInsets
      .symmetric(horizontal: 8.0, vertical: 4.0),
  "page.daily-attendance.task-page.expansion-panel.margin": const EdgeInsets
      .all(4.0),
  "page.daily-attendance.task-page.expansion-panel.decoration": const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.2)
        ),
      ]
  ),

  "page.daily-attendance.statistics.panel.item.padding": const EdgeInsets.all(8.0),
  "page.daily-attendance.statistics.panel.item.margin": const EdgeInsets.all(8.0),
  "page.daily-attendance.statistics.panel.item.margin.mobile": const EdgeInsets.all(4.0),
  "page.daily-attendance.statistics.week.panel.item.size": 32.0,
  "page.daily-attendance.statistics.week.panel.item.size.mobile": 24.0,
  "page.daily-attendance.statistics.week.panel.font.size": 16.0,
  "page.daily-attendance.statistics.panel.padding": const EdgeInsets.all(16.0),
  "page.daily-attendance.statistics.panel.padding.mobile": const EdgeInsets.all(4.0),
  "page.daily-attendance.statistics.panel.width": 600.0,
  "page.daily-attendance.statistics.panel.margin": const EdgeInsets.only(top: 8),
  "page.daily-attendance.statistics.panel.decoration": const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.2)
        )
      ]
  ),

  "page.daily-attendance.statistics.change-week.margin-bottom": 16.0,

  "page.daily-attendance.statistics.month.panel.calendar.item.size": 8.0,
  "page.daily-attendance.statistics.month.panel.calendar.item.margin": const EdgeInsets.all(4.0),
  "page.daily-attendance.statistics.month.panel.calendar.head.margin-bottom": 16.0,

  "page.daily-attendance.taskpage.appbar.text-style": const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 32.0
  ),

  "widget.home.clipboard.height": 400.0,
  "widget.home.clipboard.listview.text-style": const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  "widget.home.clipboard.decoration": const BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
          color: Color.fromRGBO(0, 0, 0, 0.1)
      )
    ]
  ),

  "widget.home.pomodoro.decoration": const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
            color: Color.fromRGBO(0, 0, 0, 0.1)
        )
      ]
  ),

  "widget.home.clipboard.margin": 24.0,

  "widget.home.pomodoro.center.text-style": const TextStyle(
    fontSize: 24
  ),

  "widget.home.pomodoro.margin": 16.0,
  "widget.home.clipboard.padding": const EdgeInsets.all(8.0),

  "page.home.padding": const EdgeInsets.all(16.0),

  "page.preload-page.margin": 16.0,
  "page.preload-page.item.margin": const EdgeInsets.symmetric(vertical: 8)
};

final navigatorKey = GlobalKey<NavigatorState>();
final globalNavigatorKey = GlobalKey<NavigatorState>();
final todolistNavigatorKey = GlobalKey<NavigatorState>();
final dailyAttendnaceNavigatorKey = GlobalKey<NavigatorState>();
final sambaNavigatorKey = GlobalKey<NavigatorState>();
final settingsNavigatorKey = GlobalKey<NavigatorState>();

const Map<String, String> routes = {
  "home": "/",
  "todolist": "/todolist",
  "daily-attendance": "/daily-attendance",
  "samba": "/samba",
  "settings": "/settings"
};

const Map<String, String> todolistRoutes = {
  "taskproject": "/todolist",
  "taskgroup-board": "/board",
  "taskdetail": "/detail",
  "pomodoro": "/pomodoro"
};


const Map<String, String> dailyAttendanceRoutes = {
  "taskpage": "/daily-attendance",
  "taskadd": "/add",
  "taskedit": "/edit",
  "task-recording": "/recording",
  "statistics": "/statistics",
  "color-select": "/color-select",
  "task-manage": "/task-manage"
};

const keyOfConfigured = "isconfigured";
const keyOfJwtToken = "jwttoken";
const keyOfBackendUrl = "backend-url";
const keyOfNickname = "nickname";
const keyOfSambaHostUrl = "samba-host-url";
const keyOfSambaUser = "samba-user";
const keyOfSambaPassword = "samba-password";
const keyOfClipboardUrl = "clipboard-url";

final logger = Logger(
  filter: null,
  printer: PrettyPrinter(),
  output: null
);

IOWebSocketChannel? socket;