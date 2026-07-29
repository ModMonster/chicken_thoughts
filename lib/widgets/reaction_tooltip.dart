import 'package:chicken_thoughts_notifications/data/reaction.dart';
import 'package:chicken_thoughts_notifications/pages/settings_user.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

class ReactionTooltip extends StatelessWidget {
  final Reaction reaction;
  final void Function() delete;
  const ReactionTooltip(this.reaction, {required this.delete, super.key});

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
  Widget build(BuildContext context) {
    return Card.filled(
      child: SizedBox(
        width: 300,
        height: 72,
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(16.0, 0, 8.0, 0),
          leading: CircleAvatar(
            backgroundColor: userColors[reaction.user.iconBg],
            child: Text(userEmojis[reaction.user.iconFg]),
          ),
          title: Text(reaction.user.name),
          subtitle: reaction.timestamp != null? Text(formatDate(reaction.timestamp!)) : null,
          trailing: reaction.user.id == Hive.box("settings").get("user.id")? IconButton(
            onPressed: delete,
            icon: Icon(Icons.delete_outline),
            tooltip: "Delete",
          ) : null,
        ),
      ),
    );
  }
}