import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class Pages extends StatefulWidget {
  final List<Widget> children;

  Pages({required this.children});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  late final PageController controller;

  void Function(void Function())? _setStateOther;
  void Function(void Function()) get setStateOther => _setStateOther!;
  set setStateOther(void Function(void Function()) value) => _setStateOther ??= value;

  @override
  void initState() {
    super.initState();
    controller = PageController()..addListener(() {
      if (_setStateOther != null) {
        setStateOther(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: widget.children,
            ),
          ),

          StatefulBuilder(builder: (context, setState) {
            setStateOther = setState;

            return buildFooter(context);
          })

        ],
      ),
    );
  }

  Widget buildFooter(BuildContext context) {
    int length = widget.children.length;

    int page = controller.page?.floor() ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: settings["common.unit.size"]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(length, (index) => buildFooterItem(context, page == index)).toList()
      ),
    );
  }

  Widget buildFooterItem(BuildContext context, bool flag) {
    return Container(
      width: settings["common.unit.size"],
      height: settings["common.unit.size"],
      margin: EdgeInsets.all(settings["common.unit.size"]),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: flag ? const Color.fromRGBO(0, 0, 0, 0.3) : const Color.fromRGBO(0, 0, 0, 0.1)
      ),
    );
  }
}