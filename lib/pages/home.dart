import 'package:chicken_thoughts_notifications/data/app_data.dart';
import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/settings.dart';
import 'package:chicken_thoughts_notifications/views/chickendex.dart';
import 'package:chicken_thoughts_notifications/views/daily.dart';
import 'package:chicken_thoughts_notifications/views/history.dart';
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
  const HomePage({required this.hasDynamicColor, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Future<ChickenThought> _dailyChickenThoughtFuture = DatabaseManager.getDailyChickenThought();
  DateTime _lastCheckedDay = DateTime.now();

  Future<void> showUpdateDialog() async {
    // Check for updates and show update dialog if necessary
    AppData appData = await DatabaseManager.getRemoteAppData();

    if (appData.offline) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, "/offline"));
    }

    // Skip on web lol
    if (kIsWeb) return;

    // App requires an update
    if (appData.minVersion > versionCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        showDialog(context: context, barrierDismissible: false, builder: (context) {
          return UpdateDialog(required: true);
        })
      );
      return;
    }

    // App can update
    if (appData.latestVersion > versionCode && Hive.box("settings").get("update_notifications", defaultValue: true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        showDialog(context: context, builder: (context) {
          return UpdateDialog(required: false);
        })
      );
    }
  }

  // void showCacheInvalidDialog() async {
  //   if (kIsWeb) return;
  //   if (!Hive.box("settings").get("caching.enable", defaultValue: false)) return;

  //   // Get local and remote cache versions
  //   int localCacheVersion = await CacheManager.getLocalCacheVersion();
  //   int remoteCacheVersion = await DatabaseManager.getRemoteCacheVersion();

  //   // App requires an update
  //   if (remoteCacheVersion > localCacheVersion) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) =>
  //       showDialog(context: context, barrierDismissible: false, builder: (context) {
  //         return PopScope(
  //           canPop: false,
  //           child: AlertDialog(
  //             title: const Text("Cache error"),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               spacing: 16,
  //               children: [
  //                 Text("You have caching enabled, but your downloaded cache is out of date."),
  //                 Text("Please visit the settings page to update your caches!"),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pushReplacementNamed(context, "/settings/caching", arguments: remoteCacheVersion);
  //                 },
  //                 child: Text("Open settings")
  //               )
  //             ],
  //           ),
  //         );
  //       })
  //     );
  //   }
  // }

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
        // TODO: holidays will DEF MESS THIS UP
        // FIX THIS WITH MIMI'S IDEA (ONE BIG LIST, NO holiday.christmas.jpg JUST ONE BIG LIST AND MAP EACH NUM INSIDE THE DATABASE)
        Hive.box("chickendex").put(snapshot.data!.id, snapshot.data!.images.length);
    
        List<Widget> screens = [
          DailyView(chickenThought: snapshot.data!),
          HistoryView(),
          ChickendexView()
        ];
    
        if (mobile) {
          return MobileScaffold(screens);
        } else {
          return WebScaffold(screens..add(SettingsPage(hasDynamicColor: widget.hasDynamicColor)));
        }
      }
    );
  }
}
