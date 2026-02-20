import 'package:animations/animations.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:flutter/material.dart';
import 'package:navigation_rail_m3e/navigation_rail_m3e.dart';

class WebScaffold extends StatefulWidget {
  final List<Widget> screens;
  const WebScaffold(this.screens, {super.key});

  @override
  State<WebScaffold> createState() => _WebScaffoldState();
}

class _WebScaffoldState extends State<WebScaffold> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    bool xl = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body: Row(
        children: [
          NavigationRailM3E(
            type: xl? NavigationRailM3EType.expanded : NavigationRailM3EType.collapsed,
            sections: [
              NavigationRailM3ESection(
                destinations: [
                  NavigationRailM3EDestination(
                    icon: Icon(Icons.photo_outlined),
                    selectedIcon: Icon(Icons.photo),
                    label: "Daily"
                  ),
                  NavigationRailM3EDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: "History"
                  ),
                  NavigationRailM3EDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view_sharp),
                    label: "Chickendex"
                  ),
                  NavigationRailM3EDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: "Settings"
                  ),
                ]
              ),
            ],
            selectedIndex: currentPage,
            onDestinationSelected: (index) {
              setState(() {
                currentPage = index;
              });
              Vibrate.tap();
            },
          ),
          Expanded(
            child: PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
                FadeThroughTransition(animation: primaryAnimation, secondaryAnimation: secondaryAnimation, child: child),
              child: widget.screens[currentPage]
            ),
          ),
        ],
      ),
    );
  }
}