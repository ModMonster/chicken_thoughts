import 'dart:math';

import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/hole_painter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class ReactionPlacementOverlay extends StatefulWidget {
  final Rect imageRect;
  final Emoji emoji;
  final String chickenThoughtId;
  const ReactionPlacementOverlay({super.key, required this.imageRect, required this.emoji, required this.chickenThoughtId});

  @override
  State<ReactionPlacementOverlay> createState() => _ReactionPlacementOverlayState();
}

class _ReactionPlacementOverlayState extends State<ReactionPlacementOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController wiggleController;

  @override
  void initState() {
    wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    wiggleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: CustomPaint(
              painter: HolePainter(widget.imageRect),
            )
          ),
      
          // Clickable image area (add reaction)
          Positioned.fromRect(
            rect: widget.imageRect,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                Offset tap = details.globalPosition;

                double x = (tap.dx - widget.imageRect.left) / widget.imageRect.width;
                double y = (tap.dy - widget.imageRect.top) / widget.imageRect.height;

                Navigator.pop(context);
                DatabaseManager.addReaction(widget.chickenThoughtId, widget.emoji.emoji, x, y);
              },
              child: SizedBox.expand(),
            ),
          ),

          // Text and buttons
          Positioned(
            top: widget.imageRect.bottom + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Text("Tap on the image to place the reaction!"),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                )
              ],
            ),
          ),

          // Emoji preview
          Positioned(
            top: widget.imageRect.bottom + 64,
            left: 16,
            right: 16,
            child: Center(
              child: AnimatedBuilder(
                animation: wiggleController,
                builder: (context, child) {
                  double angle = wiggleController.value * 2 * pi;

                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * 2,
                      sin(angle) * 2
                    ),
                    child: child,
                  );
                },
                child: Text(
                  widget.emoji.emoji,
                  style: TextStyle(
                    fontSize: 36
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}