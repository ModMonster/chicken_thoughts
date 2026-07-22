import 'package:flutter/material.dart';

class HolePainter extends CustomPainter {
  Rect hole;
  HolePainter(this.hole);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Create a transparent layer
    canvas.saveLayer(Offset.zero & size, Paint());

    // Draw the dark overlay
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black54);

    // Cut the hole
    canvas.drawRect(hole, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HolePainter old) {
    return old.hole != hole;
  }
}