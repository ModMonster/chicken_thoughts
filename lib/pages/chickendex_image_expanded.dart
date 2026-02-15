import 'dart:typed_data';

import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/material.dart';

class ChickendexImageExpandedPage extends StatefulWidget {
  final int index;
  final Uint8List thumbImage;
  const ChickendexImageExpandedPage(this.index, {required this.thumbImage, super.key});

  @override
  State<ChickendexImageExpandedPage> createState() => _ChickendexImageExpandedPageState();
}

class _ChickendexImageExpandedPageState extends State<ChickendexImageExpandedPage> {
  final CarouselController _carouselController = CarouselController();
  late final Future<List<Uint8List>> _future;

  @override
  void initState() {
    _future = DatabaseManager.getImagesFromPath(widget.index.toString());
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
          title: Text("Chicken Thought #${widget.index}"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: widget.index,
                    child: FutureBuilder(
                      future: _future,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return SizedBox.expand(
                            child: Image.memory(
                              widget.thumbImage,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                            
                        return Image.memory(
                          snapshot.data!.first,
                          fit: BoxFit.contain,
                        );
                      }
                    ),
                  ),
                ),
              ),
              Text("1/100"),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 70),
                child: CarouselView.weighted(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)
                  ),
                  padding: EdgeInsets.all(1),
                  flexWeights: [2, 2, 2, 2, 3, 2, 2, 2, 2],
                  itemSnapping: true,
                  controller: _carouselController,
                  onTap: (index) {
                    setState(() {
                      _carouselController.animateToItem(index);
                    });
                  },
                  children: List<Widget>.generate(20, (int index) {
                    return Image.memory(
                      widget.thumbImage,
                      fit: BoxFit.cover,
                      // color: Colors.black.withAlpha(50),
                      // colorBlendMode: BlendMode.darken,
                    );
                  })
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}