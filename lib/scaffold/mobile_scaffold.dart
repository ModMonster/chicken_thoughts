import 'package:animations/animations.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:flutter/material.dart';

class MobileScaffold extends StatefulWidget {
  final List<Widget> screens;
  final ValueNotifier<int> currentPageNotifier;
  const MobileScaffold(this.screens, {required this.currentPageNotifier, super.key});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.currentPageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          body: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              FadeThroughTransition(animation: primaryAnimation, secondaryAnimation: secondaryAnimation, child: child),
            child: widget.screens[value]
          ),
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.photo_outlined),
                selectedIcon: Icon(Icons.photo),
                label: "Daily"
              ),
              NavigationDestination(
                icon: Icon(Icons.local_fire_department_outlined),
                selectedIcon: Icon(Icons.local_fire_department),
                label: "Streak"
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_sharp),
                label: "Chickendex"
              ),
            ],
            selectedIndex: value,
            onDestinationSelected: (index) {
              widget.currentPageNotifier.value = index;
              Vibrate.tap();
            },
          ),
        );
      }
    );
  }
}