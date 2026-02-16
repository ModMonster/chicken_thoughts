

import 'dart:io' as io;
import 'dart:io';

import 'package:appwrite/models.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:proper_filesize/proper_filesize.dart';

class CacheManager {
  static late final Directory cacheDir;
  
  static Future<void> init() async {
    if (kIsWeb) return;
    cacheDir = await _getCacheDir();
  }

  static Future<Directory> _getCacheDir() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory cacheDir = Directory(path.join(dir.path, "caches"));
    await cacheDir.create(recursive: true);
    return cacheDir;
  }

  static String getCachePath(String filename) {
    return path.join(cacheDir.path, filename);
  }

  static Stream<DownloadInfo> downloadCaches() async* {
    FileList files = await DatabaseManager.getAllFiles();
    if (kDebugMode) print("Files: ${files.total}");

    int currentFilesize = 0;
    int downloaded = 0;
    for (File file in files.files) {
      yield DownloadInfo(current: downloaded, total: files.total, currentFilesize: currentFilesize, filename: file.name);

      Uint8List bytes = await DatabaseManager.downloadFile(file.$id);
      final ioFile = io.File(getCachePath(file.name));
      ioFile.writeAsBytes(bytes);

      downloaded++;
      currentFilesize += file.sizeOriginal;
    }
  }

  static Future<void> deleteCaches() async {
    if (kDebugMode) print("Deleting from ${cacheDir.path}");
    await cacheDir.delete(recursive: true);
  }

  static Future<int> getLocalCacheSize() async {
    int size = 0;

    for (FileSystemEntity entity in cacheDir.listSync(recursive: true)) {
      if (entity is! io.File) continue;
      size += entity.lengthSync();
    }

    return size;
  }

  static String formatSize(int bytes) {
    String formattedSize = FileSize.fromBytes(bytes).toString(
      unit: Unit.auto(size: bytes, baseType: BaseType.metric),
      decimals: 1,
    );
    return formattedSize;
  }

  static Future<List<Uint8List>?> getImagesFromPath(String path) async {
    // Return null if on web or cache disabled
    if (kIsWeb) return null;
    if (!Hive.box("settings").get("caching.enable", defaultValue: false)) return null;

    List<Uint8List> images = [];
    Uint8List? normalImage = await _getImageFromFilePath("$path.jpg");
    if (normalImage != null) images.add(normalImage);

    // Try getting variations (i.e. __.1.jpg, __.2.jpg)
    Uint8List? variationImage;
    int counter = 1;
    do {
      variationImage = await _getImageFromFilePath("$path.$counter.jpg");
      if (variationImage != null) images.add(variationImage);
    } while (variationImage != null);

    return images;
  }

  static Future<Uint8List?> _getImageFromFilePath(String filePath) async {
    String absolutePath = path.join(cacheDir.path, filePath);
    io.File file = io.File(absolutePath);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }
}

class DownloadInfo {
  int current;
  int total;
  int currentFilesize;
  String? filename;

  DownloadInfo({required this.current, required this.total, required this.currentFilesize, this.filename});
}