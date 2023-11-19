import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/utils.dart';

class ColorSelect extends StatelessWidget {
  final colors = [
    HexColor.fromHex("#eccc68"),
    HexColor.fromHex("#ff7f50"),
    HexColor.fromHex("#ff6b81"),
    HexColor.fromHex("#a4b0be"),
    HexColor.fromHex("#57606f"),
    HexColor.fromHex("#ffa502"),
    HexColor.fromHex("#ff6348"),
    HexColor.fromHex("#ff4757"),
    HexColor.fromHex("#747d8c"),
    HexColor.fromHex("#2f3542"),
    HexColor.fromHex("#7bed9f"),
    HexColor.fromHex("#70a1ff"),
    HexColor.fromHex("#5352ed"),
    HexColor.fromHex("#ffffff"),
    HexColor.fromHex("#dfe4ea"),
    HexColor.fromHex("#2ed573"),
    HexColor.fromHex("#1e90ff"),
    HexColor.fromHex("#3742fa"),
    HexColor.fromHex("#f1f2f6"),
    HexColor.fromHex("#ced6e0"),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            navigatorKey.currentState?.pop(null);
          },

          icon: const Icon(Icons.close),
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: settings["page.daily-attendance.color-select.grid.aspect-ratio"]
      ),

      itemCount: colors.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          navigatorKey.currentState?.pop(colors[index]);
        },

        child: Container(
          color: colors[index],
        ),
      )
    );
  }
}