import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_grid_image.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

class ChickendexHolidayView extends StatefulWidget {
  const ChickendexHolidayView({super.key});

  @override
  State<ChickendexHolidayView> createState() => _ChickendexHolidayViewState();
}

class _ChickendexHolidayViewState extends State<ChickendexHolidayView> {
  final Future<List<Holiday>> _holidayFuture = DatabaseManager.getHolidayList();

  int getUnlockedCount() {
    int count = 0;
    final Box box = Hive.box("chickendex");
    for (String id in box.keys) {
      List<String> split = id.split(".");
      if (split[0] == "holiday") {
        count++;
      }
    }
    return count;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _holidayFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: LoadingIndicatorM3E());
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("Holidays"),
              subtitle: Text(
                "${getUnlockedCount()}/${snapshot.data!.length} unlocked"
              ),
            ),
            AnimationLimiter(
              child: Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    const double size = 128.0;
                    final int crossAxisCount = (availableWidth / size).floor();
                
                    return GridView.builder(
                      itemCount: snapshot.data!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8
                      ),
                      padding: EdgeInsets.all(8),
                      itemBuilder: (context, inp) {
                        Holiday holiday = snapshot.data![inp];
                        bool locked = Hive.box("chickendex").get("holiday.${holiday.name}", defaultValue: 0) == 0;
                
                        // We haven't seen it yet; locked!
                        if (locked) {
                          return AnimationConfiguration.staggeredGrid(
                            position: inp,
                            duration: const Duration(milliseconds: 375),
                            columnCount: crossAxisCount,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: ChickendexLocked(id: holiday.displayName)
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
                              child: ChickendexGridImage("holiday.${holiday.name}", displayName: holiday.displayName)
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
        );
      }
    );
  }
}