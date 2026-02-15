import 'dart:typed_data';

import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChickendexPhotoViewCarouselItem extends StatefulWidget {
  final String fileName;
  final void Function()? onTap;
  final void Function(Uint8List thumbnail)? onLoadThumbnail;
  const ChickendexPhotoViewCarouselItem(this.fileName, {this.onTap, this.onLoadThumbnail, super.key});

  @override
  State<ChickendexPhotoViewCarouselItem> createState() => _ChickendexPhotoViewCarouselItemState();
}

class _ChickendexPhotoViewCarouselItemState extends State<ChickendexPhotoViewCarouselItem> {
  late final Future<Uint8List> _future;

  @override
  void initState() {
    _future = DatabaseManager.getImagePreviewFromPath(widget.fileName);
    if (widget.onLoadThumbnail != null) {
      _future.then((value) => widget.onLoadThumbnail!(value));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: you can't whip it. you should be able to whip it
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