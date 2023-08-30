import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorFetching extends StatelessWidget {
  const ErrorFetching({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        kIsWeb? Container() : ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.purple,
            BlendMode.lighten
          ),
          child: SizedBox(
            width: 200,
            child: Lottie.asset(
              "assets/loader_error.json",
              repeat: false,
            ),
          ),
        ),
        Text("Could not fetch Chicken Thoughts :("),
        Text("Check your internet connection.")
      ],
    );
  }
}