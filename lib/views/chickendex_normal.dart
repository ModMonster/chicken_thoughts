import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_grid_image.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

class ChickendexNormalView extends StatelessWidget {
  const ChickendexNormalView({super.key});

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("chickendex");

    return FutureBuilder(
      future: DatabaseManager.getDefaultSeason(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              )
            )
          );
        }
        return SliverGrid.builder(
          itemCount: snapshot.data!.imageCount,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 96,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8
          ),
          itemBuilder: (context, inp) {
            int index = inp + 1;

            // We haven't seen it yet; locked!
            if (!box.get(index.toString(), defaultValue: false) && !box.get("$index.1", defaultValue: false)) {
              return ChickendexLocked(index);
            }

            bool isMulti = box.get("$index.1", defaultValue: false);
            
            // We have seen it; show it!
            return ChickendexGridImage(isMulti? "$index.1" : index.toString());
          }
        );
      }
    );
  }
}