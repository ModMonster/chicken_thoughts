import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:chicken_thoughts_notifications/pages/daily.dart';
import 'package:chicken_thoughts_notifications/pages/history.dart';
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

    if (chickyMap.isNotEmpty) {
      return Scaffold(
        body: PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            FadeThroughTransition(animation: primaryAnimation, secondaryAnimation: secondaryAnimation, child: child),
          child: screens[currentPage]
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.photo),
              label: "Daily"
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: "History"
            ),
          ],
          selectedIndex: currentPage,
          onDestinationSelected: (index) {
            setState(() {
              currentPage = index;
            });
          },
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
