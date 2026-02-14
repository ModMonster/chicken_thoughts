import 'dart:math' as math;

import 'package:flutter/material.dart';

class ComingSoonView extends StatelessWidget {
  final String title;
  const ComingSoonView(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          transform: GradientRotation(math.pi / 4 + math.pi / 8),
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple
          ]
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
        ),
        body: Transform.rotate(
          angle: -math.pi / 8,
          child: Center(
            child: Text(
              "COMING SOON!",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          )
        ),
      ),
    );
  }
}