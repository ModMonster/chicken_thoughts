import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:chicken_thoughts_notifications/views/coming_soon.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_grid_image.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_ce/hive.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class ChickendexView extends StatefulWidget {
  const ChickendexView({super.key});

  @override
  State<ChickendexView> createState() => _ChickendexViewState();
}

class _ChickendexViewState extends State<ChickendexView> {
  final Future<Season> _future = DatabaseManager.getDefaultSeason();

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("chickendex");

    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: LoadingIndicatorM3E()
            );
          }
      
          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [SliverAppBar(
                  title: const Text("Chickendex"),
                  pinned: true,
                  snap: true,
                  floating: true,
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        text: "Normal",
                        icon: Icon(Icons.photo),
                      ),
                      Tab(
                        text: "Seasonal",
                        icon: Icon(Icons.ac_unit),
                      ),
                      Tab(
                        text: "Unlocked",
                        icon: Icon(Icons.lock_open),
                      )
                    ],
                  ),
                  actions: [
                    if (MediaQuery.of(context).size.width <= 600) IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/settings");
                      },
                      icon: Icon(Icons.settings),
                      tooltip: "Settings",
                    )
                  ],
                )];
              },
              body: TabBarView(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          "${box.length}/${snapshot.data!.imageCount} unlocked"
                        ),
                        trailing: OutlinedButton.icon(
                          onPressed: () {
                            Vibrate.tap();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChickendexImageExpandedPage()));
                          },
                          icon: Icon(Icons.browse_gallery),
                          label: Text("View all"),
                        ),
                      ),
                      AnimationLimiter(
                        child: Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double availableWidth = constraints.maxWidth;
                              const double size = 96.0;
                              final int crossAxisCount = (availableWidth / size).floor();
                          
                              return GridView.builder(
                                itemCount: snapshot.data!.imageCount,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8
                                ),
                                padding: EdgeInsets.all(8),
                                itemBuilder: (context, inp) {
                                  int index = inp + 1;
                                  int imageCount = box.get(index.toString(), defaultValue: 0);
                                          
                                  // We haven't seen it yet; locked!
                                  if (imageCount == 0) {
                                    return AnimationConfiguration.staggeredGrid(
                                      position: inp,
                                      duration: const Duration(milliseconds: 375),
                                      columnCount: crossAxisCount,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: ChickendexLocked(index.toString())
                                        )
                                      )
                                    );
                                  }
                                  
                                  // We have seen it; show it!
                                  return AnimationConfiguration.staggeredGrid(
                                    position: inp,
                                    duration: const Duration(milliseconds: 375),
                                    columnCount: crossAxisCount,
                                    child: ScaleAnimation(
                                      child: FadeInAnimation(
                                        child: ChickendexGridImage(imageCount > 1? "$index.1" : index.toString())
                                      )
                                    )
                                  );
                                }
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
                  ComingSoonView("seasonal"),
                  ComingSoonView("all")
                ],
              )
            ),
          );
        }
      ),
    );
  }
}