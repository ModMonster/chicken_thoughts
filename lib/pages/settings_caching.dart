import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/settings_caching_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingsCachingPage extends StatefulWidget {
  const SettingsCachingPage({super.key});

  @override
  State<SettingsCachingPage> createState() => _SettingsCachingPageState();
}

class _SettingsCachingPageState extends State<SettingsCachingPage> {
  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("Caching"),
          ),
          SliverSafeArea(
            bottom: true,
            top: false,
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 18,
                    children: [
                      Icon(Icons.info_outline),
                      Expanded(
                        child: Text(
                          "Store Chicken Thoughts on your device. This uses more storage, but will result in faster loading times.",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        )
                      ),
                    ]
                  ),
                ),
                SwitchListTile(
                  title: Text("Enable caching"),
                  value: box.get("caching.enable", defaultValue: false),
                  secondary: Icon(Icons.cached_outlined),
                  onChanged: (value) async {
                    if (value) {
                      // Enabling caching
                      showDialog(context: context, builder: (context) => FutureBuilder(
                        future: DatabaseManager.getRemoteCacheSize(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.surface,
                              )
                            );
                          }

                          return AlertDialog(
                            title: Text("Enable caching?"),
                            content: Column(
                              spacing: 12.0,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("This will require ${CacheManager.formatSize(snapshot.data!)} of storage on your device."),
                                Text(
                                  "This may take a very long time!",
                                  style: Theme.of(context).textTheme.labelLarge,
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel")
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  showDialog(context: context, barrierDismissible: false, builder: (context) => SettingsCachingDialog());
                                },
                                child: Text("OK")
                              )
                            ],
                          );
                        }
                      ));
                    } else {
                      // Disabling caching
                      showDialog(context: context, barrierDismissible: false, builder: (context) => PopScope(
                        canPop: false,
                        child: AlertDialog(
                          title: Text("Deleting caches"),
                          content: LinearProgressIndicator(),
                        ),
                      ));

                      await CacheManager.deleteCaches();
                      Navigator.pop(context); // TODO: fix this
                      box.put("caching.enable", false);
                    }
                  }
                ),
                ListTile(
                  leading: Icon(Icons.file_download_outlined),
                  title: Text("Downloaded size"),
                  subtitle: box.get("caching.enable", defaultValue: false)?
                    FutureBuilder(
                      future: CacheManager.getLocalCacheSize(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text("Calculating...");
                        }

                        String formattedSize = CacheManager.formatSize(snapshot.data!);

                        return Text(formattedSize);
                      }
                    )
                  : Text("Cache off"),
                  enabled: box.get("caching.enable", defaultValue: false),
                )
              ]
            )
          )
        ]
      )
    );
  }
}