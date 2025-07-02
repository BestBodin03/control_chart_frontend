import 'package:control_chart/ui/core/layout/app_bar.dart';
import 'package:control_chart/ui/core/layout/main_menu.dart';
import 'package:flutter/material.dart';

class MainBody extends StatelessWidget {
  MainBody({Key? key, required this.page}) : super(key: key);
  Widget page;

  @override
  Widget build(BuildContext context) {
    MainBodyContext = context;

    return Scaffold(
        appBar: AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: const Color(0xFF0b1327),
          actions: <Widget>[App_Bar()],
        ),
        drawer: MainMenu(),
        body: page);
  }
}

class MainBodyContext {
}