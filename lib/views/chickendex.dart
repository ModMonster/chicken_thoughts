import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:chicken_thoughts_notifications/views/chickendex/chickendex_holiday_view.dart';
import 'package:chicken_thoughts_notifications/views/chickendex/chickendex_season_view.dart';
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
  final Future<List<Season>> _seasonListFuture = DatabaseManager.getSeasonList();
  final Future<List<Holiday>> _holidayListFuture = DatabaseManager.getHolidayList();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("chickendex");

    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          _seasonListFuture,
          _holidayListFuture
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: LoadingIndicatorM3E()
            );
          }

          // Find default season, move to top
          List<Season> seasons = snapshot.data![0] as List<Season>;
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
              return [
                SliverAppBar(
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
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(52),
                    child: SizedBox(
                      height: 52,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: seasons.length + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Row(
                              children: [
                                ActionChip(
                                  label: Text("View all"),
                                  onPressed: () {
                                    Vibrate.tap();
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      ChickendexImageExpandedPage(
                                        seasons: seasons,
                                        holidays: snapshot.data![1] as List<Holiday>,
                                      )
                                    ));
                                  },
                                  avatar: Icon(Icons.view_carousel_outlined),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: VerticalDivider(),
                                )
                              ],
                            );
                          }

                          final String displayName = index == seasons.length + 1? "Holidays" : seasons[index - 1].displayName?? "Normal";

                          return Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: ChoiceChip(
                              label: Text(displayName),
                              selected: _currentPage == index - 1,
                              onSelected: (value) {
                                Vibrate.tap();
                                setState(() {
                                  _currentPage = index - 1;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                )
              ];
            },
            body: _currentPage < seasons.length ? ChickendexSeasonView(
              key: ValueKey(_currentPage),
              seasons[_currentPage],
              seasons: seasons,
              holidays: snapshot.data![1] as List<Holiday>,
            ) : ChickendexHolidayView(
              seasons: seasons,
              holidays: snapshot.data![1] as List<Holiday>,
            ),
          );
        }
      ),
    );
  }
}