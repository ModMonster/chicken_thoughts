import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ChickendexImageExpandedPage extends StatefulWidget {
  final int startingChickenIndex;
  final Uint8List thumbImage;
  const ChickendexImageExpandedPage(this.startingChickenIndex, {required this.thumbImage, super.key});

  @override
  State<ChickendexImageExpandedPage> createState() => _ChickendexImageExpandedPageState();
}

class _ChickendexImageExpandedPageState extends State<ChickendexImageExpandedPage> {
  List<String> chickenIndexes = [];
  late int currentPage;
  late final PageController _photoController;

  @override
  void initState() {
    // Build the list of unlocked chickens
    for (String i in Hive.box("chickendex").keys) {
      if (widget.startingChickenIndex.toString() == i) {
        currentPage = chickenIndexes.length;
        _photoController = PageController(initialPage: currentPage);
      }
      chickenIndexes.add(i);
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
          title: Text("Chicken Thought #${chickenIndexes[currentPage]}"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: widget.startingChickenIndex,
                    child: PhotoViewGallery.builder(
                      itemCount: chickenIndexes.length,
                      backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface
                      ),
                      pageController: _photoController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      builder: (context, index) {
                        String chickenIndex = chickenIndexes[index];

                        return PhotoViewGalleryPageOptions.customChild(
                          maxScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained,
                          child: FutureBuilder(
                            future: DatabaseManager.getImagesFromPath(chickenIndex),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                if (index + 1 == widget.startingChickenIndex) {
                                  return Image.memory(
                                    widget.thumbImage,
                                    fit: BoxFit.contain,
                                  );
                                }
                                return Center(child: CircularProgressIndicator());
                              }
                                  
                              return Image.memory(
                                snapshot.data!.first, // TODO: include all
                                fit: BoxFit.contain,
                              );
                            }
                          )
                        );
                      }
                    ),
                  ),
                ),
              ),
              Text("${currentPage + 1}/${chickenIndexes.length}"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 70),
                  child: CarouselSlider.builder(
                    itemCount: chickenIndexes.length,
                    itemBuilder: (context, itemIndex, pageViewIndex) {
                      return Container(
                        color: Colors.blue,
                        child: Text(itemIndex.toString()),
                      );
                    },
                    options: CarouselOptions(),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}