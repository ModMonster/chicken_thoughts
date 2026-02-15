import 'dart:typed_data';

import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChickendexPhotoViewCarouselItem extends StatefulWidget {
  final String fileName;
  final void Function()? onTap;
  const ChickendexPhotoViewCarouselItem(this.fileName, {this.onTap, super.key});

  @override
  State<ChickendexPhotoViewCarouselItem> createState() => _ChickendexPhotoViewCarouselItemState();
}

class _ChickendexPhotoViewCarouselItemState extends State<ChickendexPhotoViewCarouselItem> {
  late final Future<Uint8List> _future;

  @override
  void initState() {
    _future = DatabaseManager.getImagePreviewFromPath(widget.fileName);
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
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap
                  ),
                )
              )
            ],
          ),
        );
      }
    );
  }
}