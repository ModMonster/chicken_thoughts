import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CacheManager {
  static late final Directory cacheDir;
  
  static Future<void> init() async {
    if (kIsWeb) return;
    cacheDir = await _getCacheDir();
  }

  static Future<Directory> _getCacheDir() async {
    Directory dir = await getApplicationCacheDirectory();
    Directory cacheDir = Directory(path.join(dir.path, "caches"));
    await cacheDir.create(recursive: true);
    return cacheDir;
  }

  static String getCachePath(String filename) {
    return path.join(cacheDir.path, filename);
  }

  static Future<void> clearCache() async {
    if (kDebugMode) print("Deleting from ${cacheDir.path}");
    if (!await cacheDir.exists()) return;
    for (FileSystemEntity file in cacheDir.listSync()) {
      await file.delete();
    }
  }

  static Future<void> addToCache(String id, Uint8List image) async {
    if (kIsWeb) return;

    File file = File(path.join(cacheDir.path, "$id.jpg"));
    if (!await file.exists()) await file.create();
    await file.writeAsBytes(image);

    if (kDebugMode) print("Added $id to cache!");
  }

  static Future<Uint8List?> getImageFromPath(String filePath) async {
    // Return null if on web or cache disabled
    if (kIsWeb) return null;

    String absolutePath = path.join(cacheDir.path, "$filePath.jpg");
    io.File file = io.File(absolutePath);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }
}

class DownloadInfo {
  int current;
  int total;
  int? currentFilesize;
  String? status;
  bool determinate;

  DownloadInfo({required this.current, required this.total, this.currentFilesize, this.status, this.determinate = true});
}