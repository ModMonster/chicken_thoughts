import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class SettingsCachingDialog extends StatefulWidget {
  const SettingsCachingDialog({super.key});

  @override
  State<SettingsCachingDialog> createState() => _SettingsCachingDialogState();
}

class _SettingsCachingDialogState extends State<SettingsCachingDialog> {
  late final Stream<DownloadInfo> _stream;
  bool _popped = false;

  @override
  void initState() {
    _stream = CacheManager.downloadCaches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text("Downloading caches"),
        content: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && !_popped) {
              _popped = true;
              box.put("caching.enable", true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Successfully downloaded cache files!")
                  )
                );
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.0,
              children: [
                LinearProgressIndicator(
                  value: snapshot.data != null? snapshot.data!.current / snapshot.data!.total : null,
                ),
                if (snapshot.hasData && snapshot.data != null) Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("${snapshot.data?.current} / ${snapshot.data?.total}"),
                    Spacer(),
                    Text(CacheManager.formatSize(snapshot.data!.currentFilesize))
                  ],
                )
              ],
            );
          }
        ),
      ),
    );
  }
}