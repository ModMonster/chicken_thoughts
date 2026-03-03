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
  int _currentPage = 0;

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
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(snapshot.data![index].displayName?? "Normal"),
                          selected: _currentPage == index,
                          onSelected: (value) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                ChickendexTabView(snapshot.data![_currentPage]),
              ],
            )
          );
        }
      )
    );
  }
}