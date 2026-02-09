import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class WebScaffold extends StatefulWidget {
  final List<Widget> screens;
  const WebScaffold(this.screens, {Key? key}) : super(key: key);

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
          NavigationRail(
            extended: xl,
            labelType: xl? null : NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.photo),
                label: Text("Daily")
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text("History")
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_view),
                label: Text("Chickendex")
              ),
            ],
            selectedIndex: currentPage,
            onDestinationSelected: (index) {
              setState(() {
                currentPage = index;
              });
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