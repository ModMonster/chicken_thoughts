import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ChickenSpinner extends StatelessWidget {
  const ChickenSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      // mobile version
      return Lottie.asset("assets/loader.json");
    } else {
      // web version
      return CircularProgressIndicator();
    }    
  }
}