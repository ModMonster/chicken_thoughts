import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_grid_image.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class ChickendexTabView extends StatefulWidget {
  final Season images;
  const ChickendexTabView(this.images, {super.key});

  @override
  State<ChickendexTabView> createState() => _ChickendexTabViewState();
}

class _ChickendexTabViewState extends State<ChickendexTabView> {
  int getUnlockedCount(String? prefix) {
    int count = 0;
    final Box box = Hive.box("chickendex");
    for (String id in box.keys) {
      List<String> split = id.split(".");
      if ((split.length == 1 && prefix == null) || split[0] == prefix) {
        count++;
      }
    }
    return count;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(widget.images.displayName ?? "Normal"),
          subtitle: Text(
            "${getUnlockedCount(widget.images.imagePrefix)}/${widget.images.imageCount} unlocked"
          ),
          trailing: OutlinedButton.icon(
            onPressed: () {
              Vibrate.tap();
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChickendexImageExpandedPage()));
            },
            icon: Icon(Icons.browse_gallery),
            label: Text("View all"),
          ),
        ),
        AnimationLimiter(
          child: Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                const double size = 96.0;
                final int crossAxisCount = (availableWidth / size).floor();
            
                return GridView.builder(
                  itemCount: widget.images.imageCount,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8
                  ),
                  padding: EdgeInsets.all(8),
                  itemBuilder: (context, inp) {
                    int index = inp + 1;
                    String imageId = "${widget.images.imagePrefix?? ""}.$index";
                    int imageCount = Hive.box("chickendex").get(imageId, defaultValue: 0);
            
                    // We haven't seen it yet; locked!
                    if (imageCount == 0) {
                      return AnimationConfiguration.staggeredGrid(
                        position: inp,
                        duration: const Duration(milliseconds: 375),
                        columnCount: crossAxisCount,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: ChickendexLocked(index.toString())
                          )
                        )
                      );
                    }
                    
                    // We have seen it; show it!
                    return AnimationConfiguration.staggeredGrid(
                      position: inp,
                      duration: const Duration(milliseconds: 375),
                      columnCount: crossAxisCount,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: ChickendexGridImage(imageCount > 1? "$imageId.1" : imageId)
                        )
                      )
                    );
                  }
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}