import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/models.dart';
import 'package:archive/archive.dart';
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

  static bool cancelCacheDownload = false;

  static Stream<DownloadInfo> downloadCaches() async* {
    cancelCacheDownload = false;
    FileList cacheParts = await DatabaseManager.getCacheFiles();
    if (kDebugMode) print("Cache parts: ${cacheParts.total}");

    int currentFilesize = 0;
    int downloaded = 1;

    final BytesBuilder downloadBuilder = BytesBuilder();

    for (File file in cacheParts.files) {
      yield DownloadInfo(
        current: downloaded,
        total: cacheParts.total,
        status: file.name,
        currentFilesize: currentFilesize,
        determinate: true
      );
      if (cancelCacheDownload) return;
      Uint8List bytes = await DatabaseManager.downloadFile(file.$id);
      downloadBuilder.add(bytes);

      downloaded++;
      currentFilesize += file.sizeOriginal;
    }

    if (cancelCacheDownload) return;

    // extract the zip archive to this folder
    final Uint8List zipBytes = downloadBuilder.toBytes();
    if (kDebugMode) print("Downloaded ${zipBytes.length} bytes");
    final zip = ZipDecoder().decodeBytes(zipBytes);

    if (kDebugMode) print("There are ${zip.length} files!!");

    // Extract the contents
    int index = 0;
    for (final file in zip) {
      yield DownloadInfo(
        current: index,
        total: zip.length,
        status: "Extracting",
        determinate: true
      );
      final filename = getCachePath(file.name);
      if (file.isCompressed) {
        // Create a new file and write the content
        final outFile = io.File(filename);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
      index++;
    }
    
    // Put cache version into box
    int cacheVersion = await DatabaseManager.getRemoteCacheVersion();
    Hive.box("settings").put("caching.version", cacheVersion);
  }

  static Future<void> deleteCaches() async {
    if (kDebugMode) print("Deleting from ${cacheDir.path}");
    if (!cacheDir.existsSync()) return;
    await cacheDir.delete(recursive: true);
  }

  static Future<int> getLocalCacheSize() async {
    int size = 0;
    if (!cacheDir.existsSync()) return 0;

    for (FileSystemEntity entity in cacheDir.listSync(recursive: true)) {
      if (entity is! io.File) continue;
      if (!entity.existsSync()) continue;
      size += entity.lengthSync();
    }

    return size;
  }

  static Future<int> getLocalCacheVersion() async {
    return await Hive.box("settings").get("caching.version", defaultValue: 0);
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
      counter++;
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
  int? currentFilesize;
  String? status;
  bool determinate;

  DownloadInfo({required this.current, required this.total, this.currentFilesize, this.status, this.determinate = true});
}