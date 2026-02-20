import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChickenSpinner extends StatelessWidget {
  const ChickenSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 400,
          maxWidth: 400
        ),
        child: Lottie.asset("assets/loader.json")
      ),
    );
  }
}