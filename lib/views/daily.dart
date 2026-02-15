import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_spinner.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_thought_image.dart';
import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/material.dart';

class DailyView extends StatelessWidget {
  final ChickenThought chickenThought;
  const DailyView({required this.chickenThought, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chickenThought.displayName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: Icon(Icons.settings),
            tooltip: "Settings",
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder(
              future: DatabaseManager.getImagesFromIds(chickenThought.storageIds),
              builder: (context, snapshot) {
                // Still loading
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: ChickenSpinner());      
                }

                if (snapshot.hasError) {
                  return ErrorFetching();
                }
                
                return ChickenThoughtImage(snapshot.data!);
              }
            )
          ),
        ),
      )
    );
  }
}