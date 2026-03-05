import 'package:chicken_thoughts_notifications/net/database_manager.dart';

class Holiday {
  final String name;
  final String displayName;
  final DateTime? date;
  final Weekday? weekday;
  final int? weekdayNumber;

  Holiday({required this.name, required this.displayName, this.date, this.weekday, this.weekdayNumber});
}