import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_photo_view_carousel_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

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
  final CarouselSliderController _photoController = CarouselSliderController();
  final CarouselSliderController _carouselController = CarouselSliderController();

  Map<int, Uint8List> prefetchedThumbnails = {};

  void addImagePath(String imagePath) {
    if (widget.startingImagePath == imagePath) {
      currentPage = imagePaths.length;
      if (widget.thumbImage != null) prefetchedThumbnails[imagePaths.length] = widget.thumbImage!;
    }
    imagePaths.add(imagePath);
  }

  @override
  void initState() {
    // Quick and dirty fix to sort properly (i.e. prevent 66 appearing after 650)
    List<dynamic> chickendexItems = Hive.box("chickendex").keys.toList()..sort((in1, in2) => int.parse(in1).compareTo(int.parse(in2)));

    // Build the list of unlocked chickens
    for (String id in chickendexItems) {
      int imageCount = Hive.box("chickendex").get(id);
      if (imageCount > 1) {
        for (int i = 1; i <= imageCount; i++) {
          addImagePath("$id.$i");
        }
      } else {
        addImagePath(id);
      }
    }
    if (widget.startingImagePath == null) {
      currentPage = 0;
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
                  child: CarouselSlider.builder(
                    itemCount: imagePaths.length,
                    options: CarouselOptions(
                      initialPage: currentPage,
                      aspectRatio: 1,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        if (reason == CarouselPageChangedReason.controller) return;
                        _carouselController.animateToPage(index, duration: Durations.medium1, curve: Curves.easeInOutCirc);
                        setState(() {
                          currentPage = index;
                        });
                      },
                    ),
                    carouselController: _photoController,
                    itemBuilder: (context, index, pageViewIndex) {
                      String chickenIndex = imagePaths[index];
                      return Hero(
                        tag: chickenIndex,
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
                        ),
                      );
                    },
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
                          setState(() {
                            currentPage = itemIndex;
                          });
                        },
                        onLoadThumbnail: (thumbnail) {
                          prefetchedThumbnails[itemIndex] = thumbnail;
                        },
                      ),
                    );
                  },
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    viewportFraction: 70/MediaQuery.of(context).size.width,
                    aspectRatio: 1/(70/MediaQuery.of(context).size.width),
                    initialPage: currentPage,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      if (reason == CarouselPageChangedReason.controller) return;
                      _photoController.animateToPage(index, duration: Durations.medium1, curve: Curves.easeInOutCirc);
                      setState(() {
                        currentPage = index;
                      });
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