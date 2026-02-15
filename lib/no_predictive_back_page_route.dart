import 'package:flutter/material.dart';

class NoPredictiveBackPageRoute<T> extends MaterialPageRoute<T> {
  NoPredictiveBackPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  bool get popGestureEnabled => true; // still allow back swipe

  @override
  RoutePopDisposition get popDisposition => RoutePopDisposition.doNotPop;
  
  @override
  bool get hasScopedWillPopCallback => false;
}