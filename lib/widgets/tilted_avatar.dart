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
  double _neutralX = 0.0;
  double _neutralY = 0.0;
  bool _calibrated = false;

  @override
  Widget build(BuildContext context) {
    return !kIsWeb? StreamBuilder(
      stream: accelerometerEventStream(),
      builder: (context, snapshot) {
        double rotX = 0.0;
        double rotY = 0.0;
        if (snapshot.hasData && snapshot.data != null) {
          if (!_calibrated) {
            _calibrated = true;
            _neutralX = snapshot.data!.x;
            _neutralY = snapshot.data!.y;
          }

          rotX = ((snapshot.data!.y - _neutralY) / 8).clamp(-0.4, 0.4);
          rotY = (-(snapshot.data!.x - _neutralX) / 15).clamp(-0.4, 0.4);
        }

        return TweenAnimationBuilder<Offset>(
          tween: Tween(
            end: Offset(rotX, rotY)
          ),
          duration: Durations.short3,
          builder: (context, offset, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(offset.dx)
                ..rotateY(offset.dy),
              child: child
            );
          },
          child: widget.child
        );
      }
    ) : widget.child;
  }
}