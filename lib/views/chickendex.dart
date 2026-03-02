import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/views/chickendex/chickendex_tab.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class ChickendexView extends StatefulWidget {
  const ChickendexView({super.key});

  @override
  State<ChickendexView> createState() => _ChickendexViewState();
}

class _ChickendexViewState extends State<ChickendexView> {
  final Future<List<Season>> _seasonListFuture = DatabaseManager.getSeasonList();
  final List<GlobalKey> keys = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _seasonListFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: LoadingIndicatorM3E()
            );
          }

          // Find default season, move to top
          List<Season> seasons = snapshot.data!;
          int defaultIndex = 0;
          for (int i = 0; i < seasons.length; i++) {
            if (seasons[i].imagePrefix == null) {
              defaultIndex = i;
              break;
            }
          }
          Season defaultSeason = seasons[defaultIndex];
          seasons.removeAt(defaultIndex);
          seasons.insert(0, defaultSeason);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [SliverAppBar(
                title: const Text("Chickendex"),
                pinned: true,
                snap: true,
                floating: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(snapshot.data![index].displayName?? "Normal"),
                              onPressed: () {
                                final ctx = keys[index].currentContext;
                                if (ctx == null) return;
                                Scrollable.ensureVisible(ctx);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
            body: ListView(
              children: List<Widget>.generate(
                snapshot.data!.length, (index) {
                  Season season = snapshot.data![index];
                  GlobalKey key = GlobalKey();
                  keys.add(key);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChickendexTabView(season, key: key)
                    ],
                  );
                }
              )
            )
          );
        }
      )
    );
  }
}