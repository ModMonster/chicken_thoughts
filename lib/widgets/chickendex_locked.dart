import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:flutter/material.dart';

class ChickendexLocked extends StatelessWidget {
  final int index;
  const ChickendexLocked(this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onInverseSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Vibrate.tap();
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: Text("Locked!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text("This Chicken Thought is locked."),
                  Text("It will be unlocked once you've seen it for the first time.")
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK")
                )
              ],
            );
          });
        },
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.lock),
            ),
            Positioned(
              left: 4,
              bottom: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: Theme.of(context).colorScheme.surfaceContainer
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  child: Text(
                    index.toString(),
                    style: Theme.of(context).textTheme.labelSmall
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}