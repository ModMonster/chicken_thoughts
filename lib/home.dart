import 'dart:convert';

import 'package:chicken_thoughts_notifications/pages/daily.dart';
import 'package:chicken_thoughts_notifications/pages/history.dart';
import 'package:chicken_thoughts_notifications/scaffold/mobile_scaffold.dart';
import 'package:chicken_thoughts_notifications/scaffold/web_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> chickyMap = {};
  int currentPage = 0;

  @override
  void initState() {
    getChickies();
    super.initState();
  }

  Future<void> getChickies() async {
    final file = await rootBundle.loadString("assets/chickies.json");
    chickyMap = Map<String, String>.from(await jsonDecode(file));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      DailyChickyThoughtPage(chickyMap: chickyMap),
      HistoryPage(chickyMap: chickyMap)
    ];

    bool mobile = MediaQuery.of(context).size.width < 768;

    if (chickyMap.isNotEmpty) {
      if (mobile) {
        return MobileScaffold(screens);
      } else {
        return WebScaffold(screens);
      }
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
