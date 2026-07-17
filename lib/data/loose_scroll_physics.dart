import 'package:flutter/material.dart';

class LooseScrollPhysics extends PageScrollPhysics {
  const LooseScrollPhysics({super.parent});

  @override
  LooseScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LooseScrollPhysics(parent: buildParent(ancestor));
  }

  double _pageExtent(ScrollMetrics position) {
    final page = position as dynamic;
    try {
      return position.viewportDimension * (page.viewportFraction as double);
    } catch (_) {
      return position.viewportDimension;
    }
  }

  double _getPage(ScrollMetrics position) =>
      position.pixels / _pageExtent(position);

  double _getPixels(ScrollMetrics position, double page) =>
      page * _pageExtent(position);

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);

    if (velocity.abs() > tolerance.velocity) {
      final pagesPerSecond = velocity / _pageExtent(position);
      const flickSensitivity = 0.1;
      page += pagesPerSecond * flickSensitivity;
    }

    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);

    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final target = _getTargetPixels(position, tolerance, velocity)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((target - position.pixels).abs() < tolerance.distance) {
      return null;
    }

    return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
  }
}