import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_spinner.dart';
import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/material.dart';

class ChickenThoughtImage extends StatelessWidget {
  final ChickenThought chickenThought;
  const ChickenThoughtImage(this.chickenThought, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseManager.getImageUrlFromId(chickenThought.storageIds.first), // TODO: make this into a gallery for images w/ multiple photos
      builder: (context, snapshot) {
        // Still loading
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: ChickenSpinner());      
        }

        if (snapshot.hasError) {
          return ErrorFetching();
        }

        return Image.memory(snapshot.data!);
      },
    );
  }
}