import 'package:share_plus/share_plus.dart';

class ShareManager {
  static Future<void> share() async {
    await SharePlus.instance.share(
      ShareParams(
        title: "Share Chicken Thought #...",
        subject: "Take a look at Chicken Thought #...!",
        text: "TEST",
      )
    );
  }
}