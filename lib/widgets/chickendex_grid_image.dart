import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChickendexGridImage extends StatelessWidget {
  final String imagePath;
  const ChickendexGridImage(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseManager.getImagePreviewFromPath(imagePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Shimmer(
              child: Container(
                color: Theme.of(context).colorScheme.onInverseSurface,
              )
            ),
          );
        }
    
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: imagePath,
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Vibrate.tap();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChickendexImageExpandedPage(startingImagePath: imagePath, thumbImage: snapshot.data!)));
                    },
                  ),
                )
              ),
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    color: Theme.of(context).colorScheme.surfaceContainer
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      imagePath,
                      style: Theme.of(context).textTheme.labelSmall
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}