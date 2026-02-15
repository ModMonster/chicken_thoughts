import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ChickenThoughtImage extends StatefulWidget {
  final List<Uint8List> images;
  const ChickenThoughtImage(this.images, {super.key});

  @override
  State<ChickenThoughtImage> createState() => _ChickenThoughtImageState();
}

class _ChickenThoughtImageState extends State<ChickenThoughtImage> {
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey _pageIndicatorKey = GlobalKey();

  void showMultiImageTutorial() {
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "image_viewer",
          keyTarget: _pageIndicatorKey,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Text(
                  "This Chicken Thought has multiple images! Swipe left or right to view them all!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ],
      textSkip: "OK",
    ).show(context: context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1 && !Hive.box("settings").get("seen_tutorial", defaultValue: false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showMultiImageTutorial());
      Hive.box("settings").put("seen_tutorial", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PhotoViewGallery.builder(
            backgroundDecoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            itemCount: widget.images.length,
            pageController: _pageController,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                maxScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                imageProvider: MemoryImage(widget.images[index])
              );
            },
          ),
        ),
        if (widget.images.length > 1) SmoothPageIndicator(
          key: _pageIndicatorKey,
          controller: _pageController,
          count: widget.images.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    );
  }
}