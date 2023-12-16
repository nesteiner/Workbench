import 'package:flutter/material.dart';

class KeepAliveWrapper extends StatefulWidget {
  final bool keepAlive;
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child
  });

  KeepAliveWrapperState createState() => KeepAliveWrapperState();
}

class KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    // TODO: implement didUpdateWidget
    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }

    super.didUpdateWidget(oldWidget);
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => widget.keepAlive;
}