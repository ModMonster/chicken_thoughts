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
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(Icons.lock),
              Text(
                index.toString(),
                style: TextStyle(
                  fontSize: 24
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}