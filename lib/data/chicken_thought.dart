import 'dart:typed_data';

class ChickenThought {
  String id;
  String displayName;
  List<Uint8List> images;
  Uint8List? thumbnail;

  ChickenThought(this.id, {required this.displayName, required this.images, this.thumbnail});
}