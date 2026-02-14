import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/pages/history.dart';
import 'package:chicken_thoughts_notifications/pages/photo_view.dart';
import 'package:chicken_thoughts_notifications/widgets/loading_image.dart';
import 'package:flutter/material.dart';

class DailyChickyThoughtPage extends StatelessWidget {
  const DailyChickyThoughtPage({required this.chickyMap, super.key});

  final Map<String, String> chickyMap;

  @override
  Widget build(BuildContext context) {
    int chickyNumber = ChickenThoughtDate.getCurrentChickyNumber();

    return Scaffold(
      appBar: AppBar(
        title: Text("Chicken Thought #$chickyNumber"),
        actions: [
          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationVersion: version,
                applicationIcon: CircleAvatar(backgroundImage: AssetImage("assets/icon.png")),
                children: [
                  Text("An app that sends you a new Chicken Thought every day!")
                ]
              );
            },
            icon: Icon(Icons.info_outline),
            tooltip: "Information",
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PhotoViewPage(
                      currentChickyThought: ChickenThoughtDate(
                        dateShown: "Current",
                        url: chickyMap[chickyNumber.toString()]!,
                        number: chickyNumber
                      ),
                      pastChickyThoughts: ChickenThoughtDate.getImageList(chickyMap),
                      heroTag: "mainChicken",
                    );
                  }));
                },
                child: Hero(
                  tag: "mainChicken",
                  child: LoadingImage(chickyMap[chickyNumber.toString()]!)
                )
              ),
            )
          ),
        ),
      )
    );
  }
}