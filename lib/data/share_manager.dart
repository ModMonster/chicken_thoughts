import 'dart:io';
import 'dart:typed_data';

import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareManager {
  static Future<void> share(String chickenThoughtPath, {required String displayName}) async {
    List<Uint8List> images = await DatabaseManager.getImagesFromPath(chickenThoughtPath);
    
    final tempDir = await getTemporaryDirectory();
    final List<File> shareFiles = [];

    // Write each image to a unique temp file
    for (int i = 0; i < images.length; i++) {
      final file = File('${tempDir.path}/image_$i.png');
      await file.writeAsBytes(images[i]);
      shareFiles.add(file);
    }

    await SharePlus.instance.share(
      ShareParams(
        title: displayName,
        subject: "Take a look at $displayName!",
        files: shareFiles.map((f) => XFile(f.path)).toList()
      )
    );

    for (File file in shareFiles) {
      await file.delete();
    }
  }
}