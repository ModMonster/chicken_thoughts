import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorFetching extends StatelessWidget {
  const ErrorFetching({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: Lottie.asset(
            "assets/loader_error.json",
            repeat: false,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.color(
                  ["**", "Add_cloud 2 Outlines", "**"],
                  value: Theme.of(context).colorScheme.error
                ),
                ValueDelegate.strokeColor(
                  ["**", "Line1 Outlines", "**"],
                  value: Theme.of(context).colorScheme.surface
                ),
                ValueDelegate.strokeColor(
                  ["**", "Line1 Outlines 2", "**"],
                  value: Theme.of(context).colorScheme.surface
                )
              ]
            )
          ),
        ),
        Text("Could not fetch Chicken Thoughts :("),
        Text("Please check your internet connection")
      ],
    );
  }
}