import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/views/chickendex.dart';
import 'package:chicken_thoughts_notifications/views/daily.dart';
import 'package:chicken_thoughts_notifications/views/history.dart';
import 'package:chicken_thoughts_notifications/scaffold/mobile_scaffold.dart';
import 'package:chicken_thoughts_notifications/scaffold/web_scaffold.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_spinner.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({ super.key });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    bool mobile = MediaQuery.of(context).size.width < 768;

    return FutureBuilder(
      future: DatabaseManager.getDailyChickenThought(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(child: ChickenSpinner())
          );
        }

        List<Widget> screens = [
          DailyView(chickenThought: snapshot.data!),
          HistoryView(),
          ChickendexView()
        ];

        if (mobile) {
          return MobileScaffold(screens);
        } else {
          return WebScaffold(screens);
        }
      }
    );
  }
}
