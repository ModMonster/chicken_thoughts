import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/widgets/chicken_thought_image.dart';
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
            child: Material(
              child: InkWell(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return PhotoViewPage(
                  //     currentChickyThought: ChickenThoughtDate(
                  //       dateShown: "Current",
                  //       url: chickyMap[chickyNumber.toString()]!,
                  //       number: chickyNumber
                  //     ),
                  //     pastChickyThoughts: ChickenThoughtDate.getImageList(chickyMap),
                  //     heroTag: "mainChicken",
                  //   );
                  // }));
                },
                child: Hero(
                  tag: "mainChicken",
                  child: ChickenThoughtImage(chickenThought)
                )
              ),
            )
          ),
        ),
      )
    );
  }
}