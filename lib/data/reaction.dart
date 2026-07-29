import 'dart:ui';

import 'package:chicken_thoughts_notifications/data/user.dart';

class Reaction {
  final String id;
  final String emoji;
  final Offset position;
  final DateTime? timestamp;
  final ChickenThoughtsUser user;

  Reaction({required this.id, required this.emoji, required this.position, required this.user, this.timestamp});
}