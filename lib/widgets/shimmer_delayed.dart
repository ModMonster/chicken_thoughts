import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerDelayed extends StatefulWidget {
  final Widget child;
  final Duration delay;

  final Color color;
  final double colorOpacity;
  final Duration duration;
  final Duration interval;
  final ShimmerDirection direction;

  const ShimmerDelayed({required this.child,
    this.delay = const Duration(seconds: 1),
    this.color = Colors.white,
    this.colorOpacity = 0.3,
    this.duration = const Duration(seconds: 3),
    this.interval = const Duration(seconds: 0),
    this.direction = const ShimmerDirection.fromLTRB(), super.key});

  @override
  State<ShimmerDelayed> createState() => _ShimmerDelayedState();
}

class _ShimmerDelayedState extends State<ShimmerDelayed> {
  bool _startShimmer = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay).then((_) {
      if (!mounted) return;
      setState(() {
        _startShimmer = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      enabled: _startShimmer,
      child: widget.child
    );
  }
}