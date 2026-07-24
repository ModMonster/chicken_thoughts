import 'dart:math';

import 'package:flutter/material.dart';

class FlyingSticker extends StatefulWidget {
  const FlyingSticker({
    super.key,
    required this.emoji,
    required this.start,
    required this.end,
    required this.onFinished,

    this.duration = const Duration(milliseconds: 750),
  });

  final String emoji;
  final Offset start;
  final Offset end;
  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<FlyingSticker> createState() => _FlyingStickerState();
}

class _FlyingStickerState extends State<FlyingSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFinished();
        }
      })..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Offset quadraticBezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;

    // yah
    return Offset(
      u * u * a.dx + 2 * u * t * b.dx + t * t * c.dx,
      u * u * a.dy + 2 * u * t * b.dy + t * t * c.dy
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {    
        final position = quadraticBezier(
          widget.start,
          Offset(
            (widget.start.dx + widget.end.dx) / 2,
            min(widget.start.dy, widget.end.dy) - 100,
          ),
          widget.end,
            Curves.easeOut.transform(
            controller.value,
          )
        );
    
        return Transform.translate(
          offset: position - Offset(18, 18),
          child: child,
        );
      },
      child: Text(
        widget.emoji,
        style: TextStyle(
          fontSize: 36,
          inherit: false
        ),
      ),
    );
  }
}