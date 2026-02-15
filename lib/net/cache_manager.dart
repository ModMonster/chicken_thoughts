

import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/models.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:proper_filesize/proper_filesize.dart';

class CacheManager {
  static Future<Directory> getCacheDir() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory cacheDir = Directory(path.join(dir.path, "caches"));
    await cacheDir.create(recursive: true);
    return cacheDir;
  }

  static Future<String> getCachePath(String filename) async {
    return path.join((await getCacheDir()).path, filename);
  }

  static Stream<DownloadInfo> downloadCaches() async* {
    FileList files = await DatabaseManager.getAllFiles();
    print("Files: ${files.total}");

    int currentFilesize = 0;
    int downloaded = 0;
    for (File file in files.files) {
      yield DownloadInfo(current: downloaded, total: files.total, currentFilesize: currentFilesize, filename: file.name);

      Uint8List bytes = await DatabaseManager.downloadFile(file.$id);
      final ioFile = io.File(await getCachePath(file.name));
      ioFile.writeAsBytes(bytes);

      downloaded++;
      currentFilesize += file.sizeOriginal;
    }
  }

  static Future<void> deleteCaches() async {
    Directory cacheDir = await getCacheDir();
    print("Deleting from ${cacheDir.path}");
    await cacheDir.delete(recursive: true);
  }

  static Future<int> getLocalCacheSize() async {
    Directory cacheDir = await getCacheDir();
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
}

class DownloadInfo {
  int current;
  int total;
  int currentFilesize;
  String? filename;

  DownloadInfo({required this.current, required this.total, required this.currentFilesize, this.filename});
}