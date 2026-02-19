import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/settings_caching_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

class SettingsCachingPage extends StatefulWidget {
  const SettingsCachingPage({super.key});

  @override
  State<SettingsCachingPage> createState() => _SettingsCachingPageState();
}

class _SettingsCachingPageState extends State<SettingsCachingPage> {
  Future<void> _disableCaching(BuildContext context) async {
    // Disabling caching
    showDialog(context: context, barrierDismissible: false, builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text("Deleting caches"),
        content: LinearProgressIndicatorM3E(
          shape: ProgressM3EShape.wavy,
          size: LinearProgressM3ESize.s,
        ),
      ),
    ));

    Hive.box("settings").put("caching.enable", false);
    await CacheManager.deleteCaches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Deleted cache files from your device")
        )
      );
    });
  }

  Future<void> _enableCaching(BuildContext context) async {
    // Enabling caching
    await showDialog(context: context, builder: (context) => FutureBuilder(
      future: DatabaseManager.getRemoteCacheSize(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: LoadingIndicatorM3E(
              color: Theme.of(context).colorScheme.primary,
              variant: LoadingIndicatorM3EVariant.contained,
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
                "This may take a long time!",
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
  }

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");
    final int remoteCacheVersion = (ModalRoute.of(context)!.settings.arguments?? 0) as int;

    return StreamBuilder(
      stream: box.watch().where((event) => {"caching.version", "caching.enable"}.contains(event.key)),
      builder: (context, asyncSnapshot) {
        final bool enabled = box.get("caching.enable", defaultValue: false);
        final int localCacheVersion = box.get("caching.version", defaultValue: 0);
        final bool invalid = enabled && remoteCacheVersion > localCacheVersion;

        return PopScope(
          canPop: !invalid,
          onPopInvokedWithResult: (didPop, result) {
            
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text("Caching"),
                  leading: invalid? IconButton(
                    onPressed: () {
                      if (!box.get("caching.enable", defaultValue: false)) {
                        Navigator.pop(context);
                        return;
                      }
        
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: Text("Disable caches?"),
                        content: Text("Closing settings without updating caches will cause them to be disabled."),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              await _disableCaching(context);
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              await _disableCaching(context);
                            },
                            child: Text("OK"),
                          )
                        ],
                      ));
                    },
                    icon: Icon(Icons.close)
                  ) : null,
                ),
                SliverSafeArea(
                  bottom: true,
                  top: false,
                  sliver: SliverList.list(
                    children: [
                      if (invalid) Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text("Update caches"),
                            subtitle: Text("Your caches are out of date!"),
                            leading: Icon(Icons.update_outlined),
                            trailing: FilledButton(
                              onPressed: () async {
                                await _disableCaching(context);
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  await _enableCaching(context);
                                });
                              },
                              child: Text("Update")
                            ),
                          ),
                          Divider()
                        ],
                      ),
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
                        value: enabled,
                        secondary: Icon(Icons.cached_outlined),
                        onChanged: (value) async {
                          if (value) {
                            _enableCaching(context);
                          } else {
                            _disableCaching(context);
                          }
                        }
                      ),
                      ListTile(
                        leading: Icon(Icons.file_download_outlined),
                        title: Text("Downloaded size"),
                        subtitle: enabled?
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
                        enabled: enabled,
                      )
                    ]
                  )
                )
              ]
            )
          ),
        );
      }
    );
  }
}