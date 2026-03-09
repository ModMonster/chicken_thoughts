import 'package:chicken_thoughts_notifications/data/app_data.dart';
import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/notification_manager.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/settings.dart';
import 'package:chicken_thoughts_notifications/views/history.dart';
import 'package:chicken_thoughts_notifications/views/streak.dart';
import 'package:chicken_thoughts_notifications/views/chickendex.dart';
import 'package:chicken_thoughts_notifications/views/daily.dart';
import 'package:chicken_thoughts_notifications/scaffold/mobile_scaffold.dart';
import 'package:chicken_thoughts_notifications/scaffold/web_scaffold.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_spinner.dart';
import 'package:chicken_thoughts_notifications/widgets/update_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final bool hasDynamicColor;
  final ValueNotifier<int> currentPageNotifier;
  const HomePage({required this.hasDynamicColor, required this.currentPageNotifier, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Future<ChickenThought> _dailyChickenThoughtFuture = DatabaseManager.getDailyChickenThought();
  DateTime _lastCheckedDay = DateTime.now();
  DateTime? _lastCheckedForUpdate;
  bool _updateDialogShown = false;
  bool _mandatoryUpdateDialogShown = false;

  Future<void> showUpdateDialog() async {
    // Only check for update once every 30 seconds
    if (_lastCheckedForUpdate != null && _lastCheckedForUpdate!.isAfter(DateTime.now().subtract(Duration(seconds: 30)))) return;

    // Check for updates and show update dialog if necessary
    AppData appData = await DatabaseManager.getRemoteAppData();
    _lastCheckedForUpdate = DateTime.now();

    if (appData.offline) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, "/offline"));
    }

    // Skip on web lol
    if (kIsWeb) return;

    // App requires an update
    if (appData.minVersion > versionCode && !_mandatoryUpdateDialogShown) {
      updateAvailable = true;
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        showDialog(context: context, barrierDismissible: false, builder: (context) {
          return UpdateDialog(required: true);
        })
      );
      _updateDialogShown = true;
      _mandatoryUpdateDialogShown = true;
      return;
    }

    // App can update
    if (appData.latestVersion > versionCode) {
      updateAvailable = true;
      if (!_updateDialogShown && Hive.box("settings").get("update_notifications", defaultValue: true)) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
          showDialog(context: context, builder: (context) {
            return UpdateDialog(required: false);
          })
        );
      }
      _updateDialogShown = true;
    }
  }

  void showAppDownloadDialog() {
    if (!isAndroidWeb) return;
    if (!Hive.box("settings").get("show_download_app_prompt", defaultValue: true)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Download the app?"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Text("The Chicken Thoughts Android app has more features, like daily reminders!"),
            Text("Of course, you're still welcome to keep viewing online! :)"),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse("https://github.com/$githubRepo/releases/latest"), mode: LaunchMode.externalApplication);
                },
                icon: Icon(Icons.open_in_new),
                label: Text("Open download page")
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Hive.box("settings").put("show_download_app_prompt", true);
            },
            child: Text("Don't show again")
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Close")
          ),
        ],
      ));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) print("App has come to the foreground!");

      // Check if it is the next day
      if (!DateUtils.isSameDay(_lastCheckedDay, DateTime.now())) {
        _dailyChickenThoughtFuture = DatabaseManager.getDailyChickenThought();
        _lastCheckedDay = DateTime.now();
      }

      // Clear notifications
      NotificationManager.clearNotifications();

      // Check for updates
      showUpdateDialog();
    }
  }

  @override
  void initState() {
    showAppDownloadDialog();
    showUpdateDialog();

    // Add listener for 12 AM
    WidgetsBinding.instance.addObserver(this);
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool mobile = MediaQuery.of(context).size.width < 600;

    return FutureBuilder(
      future: _dailyChickenThoughtFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(child: ChickenSpinner())
          );
        }
    
        // Add to chicken thoughts user has seen
        // key = ID of the chicken thought
        // value = amount of chicken thoughts corresponding to this (usually 1)
        // FIX THIS WITH MIMI'S IDEA (ONE BIG LIST, NO holiday.christmas.jpg JUST ONE BIG LIST AND MAP EACH NUM INSIDE THE DATABASE)
        Hive.box("chickendex").put(snapshot.data!.id, snapshot.data!.images.length);
    
        List<Widget> screens = [
          DailyView(chickenThought: snapshot.data!, currentPageNotifier: widget.currentPageNotifier),
          HistoryView(),
          StreakView(),
          ChickendexView(),
        ];
    
        if (mobile) {
          return MobileScaffold(screens, currentPageNotifier: widget.currentPageNotifier);
        } else {
          return WebScaffold(screens..add(SettingsPage(hasDynamicColor: widget.hasDynamicColor)), currentPageNotifier: widget.currentPageNotifier);
        }
      }
    );
  }
}
