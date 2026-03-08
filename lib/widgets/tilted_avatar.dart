import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Tilted extends StatefulWidget {
  final Widget child;
  const Tilted({required this.child, super.key});

  @override
  State<Tilted> createState() => _TiltedState();
}

class _TiltedState extends State<Tilted> {
  double _rotX = 0.0;
  double _rotY = 0.0;

  double _neutralX = 0.0;
  double _neutralY = 0.0;
  bool _calibrated = false;

  StreamSubscription? _accelerometorSub;

  @override
  void initState() {
    super.initState();

    // Listen to accelerometer for rotation
    if (kIsWeb) return;
    _accelerometorSub = accelerometerEventStream().listen((event) {
      if (!mounted) return;

      if (!_calibrated) {
        _calibrated = true;
        _neutralX = event.x;
        _neutralY = event.y;
      }

      print("${event.x}, ${event.y}");
      setState(() {
        _rotX = ((event.y - _neutralY) / 10).clamp(-0.3, 0.3);
        _rotY = (-(event.x - _neutralX) / 10).clamp(-0.3, 0.3);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _accelerometorSub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return !kIsWeb? Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_rotX)
        ..rotateY(_rotY),
      child: widget.child
    ) : widget.child;
  }
}