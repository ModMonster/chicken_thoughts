import 'dart:typed_data';

class ChickenThought {
  String id;
  String displayName;
  Uint8List image;
  Uint8List? thumbnail;

  ChickenThought(this.id, {required this.displayName, required this.image, this.thumbnail});
}