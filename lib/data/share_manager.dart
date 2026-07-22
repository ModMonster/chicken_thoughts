import 'dart:io';
import 'dart:typed_data';

import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareManager {
  static Future<void> share(String chickenThoughtPath, {required String displayName}) async {
    Uint8List image = await DatabaseManager.getImageFromPath(chickenThoughtPath);
    
    final tempDir = await getTemporaryDirectory();

    // Write each image to a unique temp file
    final file = File('${tempDir.path}/share.png');
    await file.writeAsBytes(image);

    await SharePlus.instance.share(
      ShareParams(
        title: displayName,
        subject: "Take a look at $displayName!",
        files: [XFile(file.path)]
      )
    );

    await file.delete();
  }
}