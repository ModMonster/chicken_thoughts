import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_photo_view_carousel_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ChickendexImageExpandedPage extends StatefulWidget {
  final String? startingImagePath;
  final Uint8List? thumbImage;
  const ChickendexImageExpandedPage({this.startingImagePath, this.thumbImage, super.key});

  @override
  State<ChickendexImageExpandedPage> createState() => _ChickendexImageExpandedPageState();
}

class _ChickendexImageExpandedPageState extends State<ChickendexImageExpandedPage> {
  List<String> imagePaths = [];
  late int currentPage;
  late final PageController _photoController;
  final CarouselSliderController _carouselController = CarouselSliderController();

  Map<int, Uint8List> prefetchedThumbnails = {};

  @override
  void initState() {
    // Build the list of unlocked chickens
    // TODO: sort so that 69 doesn't appear after 640
    for (String i in Hive.box("chickendex").keys) {
      if (widget.startingImagePath == i) {
        currentPage = imagePaths.length;
        _photoController = PageController(initialPage: currentPage);
        if (widget.thumbImage != null) prefetchedThumbnails[imagePaths.length] = widget.thumbImage!;
      }
      imagePaths.add(i);
    }
    if (widget.startingImagePath == null) {
      currentPage = 0;
      _photoController = PageController();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // This is done to prevent the Android predictive back from activating; interrupting the hero
        // I like the hero lol
        if (!didPop) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chicken Thought #${imagePaths[currentPage]}"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: PhotoViewGallery.builder(
                    itemCount: imagePaths.length,
                    backgroundDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface
                    ),
                    pageController: _photoController,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                        _carouselController.animateToPage(index, duration: Durations.medium1, curve: Curves.easeInOutCubic);
                      });
                    },
                    builder: (context, index) {
                      String chickenIndex = imagePaths[index];
                  
                      return PhotoViewGalleryPageOptions.customChild(
                        maxScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        heroAttributes: PhotoViewHeroAttributes(tag: imagePaths[index]),
                        child: FutureBuilder(
                          future: DatabaseManager.getImageFromExactPath(chickenIndex),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              if (prefetchedThumbnails.containsKey(index)) {
                                return Image.memory(
                                  prefetchedThumbnails[index]!,
                                  fit: BoxFit.contain,
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            }
                                
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            );
                          }
                        )
                      );
                    }
                  ),
                ),
              ),
              Text("${currentPage + 1}/${imagePaths.length}"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CarouselSlider.builder(
                  itemCount: imagePaths.length,
                  itemBuilder: (context, itemIndex, pageViewIndex) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ChickendexPhotoViewCarouselItem(
                        imagePaths[itemIndex],
                        onTap: () {
                          _carouselController.animateToPage(itemIndex, duration: Durations.medium1, curve: Curves.easeInOutCubic);
                          _photoController.animateToPage(itemIndex, duration: Durations.medium1, curve: Curves.easeInOutCubic);
                        },
                        onLoadThumbnail: (thumbnail) {
                          prefetchedThumbnails[itemIndex] = thumbnail;
                        },
                      ),
                    );
                  },
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 70,
                    viewportFraction: 0.15,
                    enlargeFactor: 0.2,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    enlargeCenterPage: true,
                    initialPage: currentPage,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      if (reason == CarouselPageChangedReason.controller) return;
                      _photoController.animateToPage(index, duration: Durations.medium1, curve: Curves.easeInCubic);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}