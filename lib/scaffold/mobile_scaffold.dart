import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class MobileScaffold extends StatefulWidget {
  final List<Widget> screens;
  const MobileScaffold(this.screens, {Key? key}) : super(key: key);

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            FadeThroughTransition(animation: primaryAnimation, secondaryAnimation: secondaryAnimation, child: child),
          child: widget.screens[currentPage]
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
  }
}