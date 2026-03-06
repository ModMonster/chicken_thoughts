import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/share_manager.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_photo_view_carousel_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ChickendexImageExpandedPage extends StatefulWidget {
  final String? startingImagePath;
  final Uint8List? thumbImage;
  final List<Season> seasons;
  final List<Holiday> holidays;
  const ChickendexImageExpandedPage({this.startingImagePath, this.thumbImage, required this.seasons, required this.holidays, super.key});

  @override
  State<ChickendexImageExpandedPage> createState() => _ChickendexImageExpandedPageState();
}

class _ChickendexImageExpandedPageState extends State<ChickendexImageExpandedPage> {
  List<String> imagePaths = [];
  late int currentPage;
  PageController? _mainController;
  PageController? _carouselController;
  bool _syncMain = false;
  bool _syncCarousel = false;
  bool _snapping = true;
  bool _waitingForScrollEnd = false;
  final FocusNode _mainFocusNode = FocusNode();

  final Map<int, Uint8List> prefetchedThumbnails = {};
  final Map<String, Future<Uint8List>> _futures = {};

  void addImagePath(String imagePath) {
    if (widget.startingImagePath == imagePath) {
      currentPage = imagePaths.length;
      if (widget.thumbImage != null) prefetchedThumbnails[imagePaths.length] = widget.thumbImage!;
    }
    imagePaths.add(imagePath);
  }

  String getDisplayName(String imagePath) {
    List<String> split = imagePath.split(".");
    if (split.length == 1 || int.tryParse(split.first) != null) return "Chicken Thought #$imagePath";

    if (split.first == "holiday") {
      for (Holiday holiday in widget.holidays) {
        if (holiday.name == split.last) {
          return holiday.displayName;
        }
      }
    }

    for (Season season in widget.seasons) {
      if (split[1] == season.imagePrefix) {
        return "Chicken Thoughts: ${season.displayName} #${split.last}";
      }
    }

    return "<ERROR>";
  }

  @override
  void initState() {
    // Quick and dirty fix to sort properly (i.e. prevent 66 appearing after 650)
    List<dynamic> chickendexItems = Hive.box("chickendex").keys.toList()..sort(
      (a, b) {
        int? aNum = int.tryParse(a);
        int? bNum = int.tryParse(b);

        // Both are normal season numbers
        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }

        // Only one is a normal season number
        if (aNum != null) return -1;
        if (bNum != null) return 1;

        // Split prefix/suffix
        List<String> aSplit = a.split(".");
        List<String> bSplit = b.split(".");

        if (aSplit.first == "season") aSplit.removeAt(0);
        if (bSplit.first == "season") bSplit.removeAt(0);

        String aPrefix = aSplit.first;
        String bPrefix = bSplit.first;

        // Put holidays at the end
        if (aPrefix == "holiday" && bPrefix != "holiday") return 1;
        if (bPrefix == "holiday" && aPrefix != "holiday") return -1;

        // Compare seasons (or holiday prefix)
        int prefixCompare = aPrefix.compareTo(bPrefix);
        if (prefixCompare != 0) return prefixCompare;

        // Same season -> compare ending bit
        String aSuffix = aSplit.last;
        String bSuffix = bSplit.last;

        int? aSuffixNum = int.tryParse(aSuffix);
        int? bSuffixNum = int.tryParse(bSuffix);

        if (aSuffixNum != null && bSuffixNum != null) {
          return aSuffixNum.compareTo(bSuffixNum);
        }

        return aSuffix.compareTo(bSuffix);
      }
    );

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

  Future<void> _waitForScrollEnd() async {
    if (_waitingForScrollEnd) return;
    _waitingForScrollEnd = true;
    _snapping = false;
    while (_carouselController!.position.isScrollingNotifier.value) {
      await Future.delayed(const Duration(milliseconds: 64));
    }
    final page = _carouselController!.page?.round();
    if (page != null) {
      await _carouselController!.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    _snapping = true;
    _waitingForScrollEnd = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_carouselController == null || _mainController == null) {
      _carouselController = PageController(
        viewportFraction: 70/MediaQuery.of(context).size.width,
        initialPage: currentPage,
      )..addListener(() async {
        if (_syncMain) return;
        _syncCarousel = true;
        _mainController!.jumpTo(_carouselController!.offset / _carouselController!.viewportFraction * _mainController!.viewportFraction);
        _syncCarousel = false;
        
        await _waitForScrollEnd();
      });

      _mainController = PageController(
        initialPage: currentPage,
      )..addListener(() {
        if (_syncCarousel) return;
        _syncMain = true;
        _carouselController!.jumpTo(_mainController!.offset / _mainController!.viewportFraction * _carouselController!.viewportFraction);
        _syncMain = false;
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // This is done to prevent the Android predictive back from activating; interrupting the hero
        // I like the hero lol
        if (!didPop) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(getDisplayName(imagePaths[currentPage])),
          actions: [
            IconButton(
              onPressed: () {
                ShareManager.share();
              },
              tooltip: "Share",
              icon: Icon(Icons.share)
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: KeyboardListener(
                    focusNode: _mainFocusNode,
                    autofocus: true,
                    onKeyEvent: (event) {
                      if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        _mainController!.previousPage(duration: Durations.short1, curve: Curves.easeInOutCubic);
                      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                        _mainController!.nextPage(duration: Durations.short1, curve: Curves.easeInOutCubic);
                      }
                    },
                    child: PageView.builder(
                      itemCount: imagePaths.length,
                      controller: _mainController,
                      pageSnapping: _snapping,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        String chickenIndex = imagePaths[index];
                        if (!_futures.containsKey(chickenIndex)) {
                          _futures[chickenIndex] = DatabaseManager.getImageFromExactPath(chickenIndex);
                        }
                        
                        return Hero(
                          tag: chickenIndex,
                          child: FutureBuilder(
                            future: _futures[chickenIndex],
                            builder: (context, snapshot) {
                              Widget child;
                              if (!snapshot.hasData || snapshot.data == null) {
                                if (prefetchedThumbnails.containsKey(index)) {
                                  child = Image.memory(
                                    prefetchedThumbnails[index]!,
                                    fit: BoxFit.contain,
                                  );
                                }
                                child = AspectRatio(
                                  aspectRatio: 1,
                                  child: Shimmer(
                                    child: Container(
                                      width: double.infinity,
                                      color: Theme.of(context).colorScheme.onInverseSurface,
                                    ),
                                  ),
                                );
                              } else {
                                child = Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.contain,
                                );
                              }
                                  
                              return AnimatedSwitcher(
                                duration: Durations.medium2,
                                child: child,
                              );
                            }
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Text("${currentPage + 1}/${imagePaths.length}"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 70,
                  child: PageView.builder(
                    itemCount: imagePaths.length,
                    pageSnapping: false,
                    onPageChanged: (index) {
                      Vibrate.carousel();
                    },
                    itemBuilder: (context, itemIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ChickendexPhotoViewCarouselItem(
                          imagePaths[itemIndex],
                          onTap: () {
                            Vibrate.tap();
                            _mainController!.animateToPage(itemIndex, duration: Durations.medium2, curve: Curves.easeInOutCubic);
                          },
                          onLoadThumbnail: (thumbnail) {
                            prefetchedThumbnails[itemIndex] = thumbnail;
                          },
                        ),
                      );
                    },
                    controller: _carouselController,
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