import 'dart:ui';

import 'package:chicken_thoughts_notifications/data/reaction.dart';
import 'package:chicken_thoughts_notifications/pages/settings_user.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

class ReactionTooltip extends StatefulWidget {
  final Reaction reaction;
  final Offset position;
  final void Function() delete;
  final void Function() close;
  const ReactionTooltip(this.reaction, {required this.position, required this.delete, required this.close, super.key});

  @override
  State<ReactionTooltip> createState() => _ReactionTooltipState();
}

class _ReactionTooltipState extends State<ReactionTooltip> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  String formatDate(DateTime date) {
    DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat("'Today at' K:mm a").format(date);
    } else if (date.year == DateTime.now().year) {
      return DateFormat("MMM d 'at' K:mm a").format(date);
    } else {
      return DateFormat("MMM d, YYYY 'at' K:mm a").format(date);
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Durations.short3,
      reverseDuration: Durations.short2,
      vsync: this,
    )..forward();
  }

  Future<void> close() async {
    await controller.reverse();
    widget.close();
  }

  Future<void> delete() async {
    await controller.reverse();
    widget.delete();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double left = clampDouble(widget.position.dx - 132, 8, screenSize.width - 316);
    double top = clampDouble(widget.position.dy + 48, 8, screenSize.height - 80);

    return Stack(
      children: [
        FadeTransition(
          opacity: CurvedAnimation(
            parent: controller,
            curve: Curves.easeOut
          ),
          child: GestureDetector(
            onTap: close,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: GestureDetector(
            onTap: close,
            child: Text(
              widget.reaction.emoji,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 36),
            ),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: controller,
              curve: Interval(
                0.15, 1.0,
                curve: Curves.easeOut
              )
            ),
            child: ScaleTransition(
              scale: Tween(
                begin: 0.85,
                end: 1.0
              ).animate(CurvedAnimation(
                  parent: controller,
                  curve: Curves.easeOutBack
                )
              ),
              child: Card.filled(
                child: SizedBox(
                  width: 300,
                  height: 72,
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16.0, 0, 8.0, 0),
                    leading: CircleAvatar(
                      backgroundColor: userColors[widget.reaction.user.iconBg],
                      child: Text(userEmojis[widget.reaction.user.iconFg]),
                    ),
                    title: Text(widget.reaction.user.name),
                    subtitle: widget.reaction.timestamp != null? Text(formatDate(widget.reaction.timestamp!)) : null,
                    trailing: widget.reaction.user.id == Hive.box("settings").get("user.id")? IconButton(
                      onPressed: delete,
                      icon: Icon(Icons.delete_outline),
                      tooltip: "Delete",
                    ) : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}