import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:chicken_thoughts_notifications/data/reaction.dart';
import 'package:chicken_thoughts_notifications/data/user.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/hole_painter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class ReactionPlacementOverlay extends StatefulWidget {
  final GlobalKey chickenThoughtsImageKey;
  final Emoji emoji;
  final String chickenThoughtId;
  final void Function(BuildContext context, Reaction reaction, Offset startPosition, Offset endPosition) onPlaced;
  const ReactionPlacementOverlay({super.key, required this.chickenThoughtsImageKey, required this.emoji, required this.chickenThoughtId, required this.onPlaced});

  @override
  State<ReactionPlacementOverlay> createState() => _ReactionPlacementOverlayState();
}

class _ReactionPlacementOverlayState extends State<ReactionPlacementOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController wiggleController;
  late Rect imageRect;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Not sure why the error flash when changing to mobile view, I tried. :/
          if (widget.chickenThoughtsImageKey.currentContext != null) {
            final renderBox = widget.chickenThoughtsImageKey.currentContext!.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);
            imageRect = position & renderBox.size;
          }

          return Stack(
            children: [
              // Background
              Positioned.fill(
                child: CustomPaint(
                  painter: HolePainter(imageRect),
                )
              ),
          
              // Clickable image area (add reaction)
              Positioned.fromRect(
                rect: imageRect,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    Offset tap = details.globalPosition;
          
                    double x = (tap.dx - imageRect.left) / imageRect.width;
                    double y = (tap.dy - imageRect.top) / imageRect.height;
                    Box box = Hive.box("settings");
                    Reaction reaction = Reaction(id: ID.unique(), emoji: widget.emoji.emoji, position: Offset(x, y), timestamp: DateTime.now(), user: ChickenThoughtsUser(
                      id: box.get("user.id"),
                      name: box.get("user.name"),
                      iconFg: box.get("user.emoji"),
                      iconBg: box.get("user.color")
                    ));
          
                    Navigator.pop(context);
                    widget.onPlaced(context, reaction, Offset(MediaQuery.of(context).size.width / 2 - 18, imageRect.bottom + 8), tap);
                    DatabaseManager.addReaction(widget.chickenThoughtId, reaction);
                  },
                  child: SizedBox.expand(),
                ),
              ),
          
              // Text and buttons
              Positioned(
                top: imageRect.bottom + 8,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Text("Tap on the image to place the reaction!"),
                    Spacer(),
                    FilledButton.tonal(
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
                top: imageRect.bottom + 64,
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
          );
        }
      ),
    );
  }
}