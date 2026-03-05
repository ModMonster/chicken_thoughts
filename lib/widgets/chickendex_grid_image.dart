import 'dart:typed_data';

import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChickendexGridImage extends StatefulWidget {
  final String imagePath;
  final String? displayName;
  final List<Season> seasons;
  final List<Holiday> holidays;
  const ChickendexGridImage(this.imagePath, {this.displayName, required this.seasons, required this.holidays, super.key});

  @override
  State<ChickendexGridImage> createState() => _ChickendexGridImageState();
}

class _ChickendexGridImageState extends State<ChickendexGridImage> {
  late final Future<Uint8List> _future;

  @override
  void initState() {
    _future = DatabaseManager.getImagePreviewFromPath(widget.imagePath);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
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
                  tag: widget.imagePath,
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        ChickendexImageExpandedPage(
                          startingImagePath: widget.imagePath,
                          thumbImage: snapshot.data!,
                          seasons: widget.seasons,
                          holidays: widget.holidays,
                        )
                      ));
                    },
                  ),
                )
              ),
              Positioned(
                left: 4,
                bottom: 4,
                right: 4,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainer
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Text(
                        widget.displayName?? widget.imagePath,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 2,
                      ),
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