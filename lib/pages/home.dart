import 'package:appcheck/appcheck.dart';
import 'package:chicken_thoughts_notifications/data/app_data.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/views/chickendex.dart';
import 'package:chicken_thoughts_notifications/views/daily.dart';
import 'package:chicken_thoughts_notifications/views/history.dart';
import 'package:chicken_thoughts_notifications/scaffold/mobile_scaffold.dart';
import 'package:chicken_thoughts_notifications/scaffold/web_scaffold.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_spinner.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> showUpdateDialog() async {
    // Check for updates and show update dialog if necessary
    AppData appData = await DatabaseManager.getRemoteAppData();

    // Get app info
    final AppCheck appCheck = AppCheck();
    bool monsterAppsInstalled = await appCheck.isAppInstalled("ca.modmonster.monster_apps");

    // App requires an update
    if (appData.minVersion > versionCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        showDialog(context: context, barrierDismissible: false, builder: (context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text("Update required"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: const Text("This app version is no longer supported. Please update to the latest version using one of the following methods:"),
                  ),
                  ...buildUpdateOptions(appCheck, monsterAppsInstalled)
                ]
              ),
            ),
          );
        })
      );
      return;
    }

    // App can update
    if (appData.latestVersion > versionCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text("Update available"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: const Text("A new update is available! Please consider updating through one of the following methods:"),
                ),
                ...buildUpdateOptions(appCheck, monsterAppsInstalled)
              ]
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Skip for now")
              )
            ]
          );
        })
      );
    }
  }

  List<Widget> buildUpdateOptions(AppCheck appCheck, bool monsterAppsInstalled) {
    return [ListTile(
      title: const Text("With Monster Apps"),
      subtitle: monsterAppsInstalled? null : Text("Not installed"),
      enabled: monsterAppsInstalled,
      leading: CircleAvatar(
        child: Image.asset(
          "assets/monster_apps.png",
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
      onTap: () {
        appCheck.launchApp("ca.modmonster.app_store");
      },
    ),
    ListTile(
      title: Text("Manually"),
      subtitle: Text("Open GitHub to download the latest version"),
      leading: CircleAvatar(
        child: const Icon(Icons.download_outlined),
      ),
      onTap: () {
        launchUrl(Uri.parse("$githubUrl/releases/latest"), mode: LaunchMode.externalApplication);
      },
    )];
  }

  @override
  void initState() {
    showUpdateDialog();
    super.initState();
  }

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
