import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/pages/photo_view.dart';
import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChickenThoughtDate {
  String dateShown;
  String url;
  int number;

  ChickenThoughtDate({required this.dateShown, required this.url, required this.number});

  static List<ChickenThoughtDate> getImageList(Map<String, String> chickyMap) {
    List<ChickenThoughtDate> pastChickyThoughts = [];

    for (var i = 1; i <= 7; i++) {
      int number = Random(((DateTime.now().millisecondsSinceEpoch - 18000000) / 86400000).floor() - i).nextInt(507);
      
      pastChickyThoughts.add(ChickenThoughtDate(
        dateShown: i == 1? "Yesterday" : "$i days ago",
        url: chickyMap[number.toString()]!,
        number: number
      ));
    }

    return pastChickyThoughts;
  }

  static int getCurrentChickyNumber() {
    return Random(((DateTime.now().millisecondsSinceEpoch - 18000000) / 86400000).floor()).nextInt(507);
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({required this.chickyMap, Key? key}) : super(key: key);

  final Map<String, String> chickyMap;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ChickenThoughtDate> pastChickyThoughts = [];

  @override
  void initState() {
    pastChickyThoughts = ChickenThoughtDate.getImageList(widget.chickyMap);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text("History"),
          actions: [
            IconButton(
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationVersion: version,
                  applicationIcon: CircleAvatar(backgroundImage: AssetImage("assets/icon.png")),
                  children: [
                    Text("An app that sends you a new Chicken Thought every day!")
                  ]
                );
              },
              icon: Icon(Icons.info_outline),
              tooltip: "Information",
            )
          ],
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              double width = MediaQuery.of(context).size.width;
              double horizontalPadding = 8;

              if (width > 720) {
                horizontalPadding = (width - 720) / 2;
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
                child: Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Chicken Thought #${pastChickyThoughts[i].number}"),
                        subtitle: Text(pastChickyThoughts[i].dateShown),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  int chickyNumber = ChickenThoughtDate.getCurrentChickyNumber();

                                  return PhotoViewPage(
                                    currentChickyThought: ChickenThoughtDate(
                                      dateShown: "Current",
                                      url: widget.chickyMap[chickyNumber.toString()]!,
                                      number: chickyNumber
                                    ),
                                    pastChickyThoughts: ChickenThoughtDate.getImageList(widget.chickyMap),
                                    heroTag: "chicken$i",
                                    initialPage: i + 1,
                                  );
                                }));
                              },
                              child: Hero(
                                tag: "chicken$i",
                                child: CachedNetworkImage(
                                  errorWidget: (context, idk, progress) => ErrorFetching(),
                                  imageUrl: pastChickyThoughts[i].url,
                                  progressIndicatorBuilder: (context, url, progress) {
                                    return AspectRatio(
                                      aspectRatio: 1,
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(color: Colors.white)
                                      ),
                                    );
                                  },
                                ),
                              )
                            ),
                          )
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            childCount: 7
          ),
        ),
      ],
    );
  }
}