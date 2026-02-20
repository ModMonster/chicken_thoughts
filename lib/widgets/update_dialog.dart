import 'dart:convert';
import 'dart:io';

import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

const String updateFilename = "ca.modmonster.chicken_thoughts_notifications.update.apk";

Future<void> deleteUpdateFile() async {
  File updateFile = File(updateFilename);
  if (!await updateFile.exists()) return;
  await updateFile.delete();
}

class UpdateDialog extends StatefulWidget {
  final bool required;
  const UpdateDialog({this.required = false, super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double? _downloadProgress;

  void updateInstallProgress(int recieved, int total) {
    setState(() {
      _downloadProgress = total <= 0? null : recieved / total;
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });

    // Get target architecture
    AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;

    // Get install URL
    final http.Response response = await http.get(Uri.parse("https://api.github.com/repos/$githubRepo/releases/latest"));
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    String? targetApkUrl;

    if (kDebugMode) print("Supported architectures: ${deviceInfo.supportedAbis}");

    if (!responseJson.containsKey("assets")) {
      // TODO: more advanced error handling?
      setState(() {
        _isDownloading = false;
      });
      return;
    }

    for (Map<String, dynamic> asset in responseJson["assets"]) {
      if (asset["name"].contains("arm-v7a") && deviceInfo.supportedAbis.contains("armeabi-v7a")) {
        // 32 bit ARM
        targetApkUrl = asset["browser_download_url"];
        break;
      } else if (asset["name"].contains("arm64-v8a") && deviceInfo.supportedAbis.contains("arm64-v8a")) {
        // 64 bit ARM
        targetApkUrl = asset["browser_download_url"];
        break;
      } else if (asset["name"].contains("x86_64") && deviceInfo.supportedAbis.contains("x86_64")) {
        // 64 bit x86
        targetApkUrl = asset["browser_download_url"];
        break;
      } else {
        // Generic APK
        targetApkUrl = asset["browser_download_url"];
      }
    }

    if (kDebugMode) print("Selected download URL: $targetApkUrl");

    if (targetApkUrl == null) {
      setState(() {
        _isDownloading = false;
      });
      return;
    }
    
    // Do the download!
    Directory downloadDir = await getTemporaryDirectory();
    String apkDownloadPath = path.join(downloadDir.path, updateFilename);

    await Dio().download(
      targetApkUrl,
      apkDownloadPath,
      onReceiveProgress: updateInstallProgress
    );

    // Install the APK
    await FlutterAppInstaller().installApk(filePath: apkDownloadPath);
    SystemNavigator.pop();

    setState(() {
      _isDownloading = false;
      _downloadProgress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDownloading && !widget.required,
      child: AlertDialog(
        title: Text("Update ${widget.required? "required" : "available"}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(widget.required?
                "This app version is no longer supported." :
                "A new update is available!"),
            ),
            Row(
              children: [
                if (!widget.required) AnimatedContainer(
                  duration: Durations.medium2,
                  curve: Curves.easeInOutCubic,
                  width: _isDownloading? 0 : 90,
                  child: AnimatedOpacity(
                    duration: Durations.medium2,
                    curve: Curves.easeInOutCubic,
                    opacity: _isDownloading? 0.0 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OutlinedButton(
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          height: 20,
                          child: Text(
                            "Skip",
                            overflow: TextOverflow.clip,
                          )
                        ),
                        onPressed: () {
                          Vibrate.tap();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: _isDownloading? null : () {
                      Vibrate.tap();
                      _startDownload();
                    },
                    child: AnimatedSwitcher(
                      duration: Durations.medium2,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: _isDownloading? LinearProgressIndicatorM3E(
                        value: _downloadProgress,
                        inset: 12.0,
                        size: LinearProgressM3ESize.m,
                      ) : const Text("Download")
                    ),
                  ),
                ),
              ],
            )
          ]
        ),
      )
    );
  }
}