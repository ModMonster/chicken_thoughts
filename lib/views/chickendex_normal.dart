import 'package:chicken_thoughts_notifications/net/database_manager.dart';
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
            if (index != 1 && box.get(index) == null) {
              return ChickendexLocked(index);
            }
            
            // We have seen it; show it!
            return Material(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder(
                future: DatabaseManager.getImagePreviewFromPath(index.toString(), imageSize: 96),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator()
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              ),
            );
          }
        );
      }
    );
  }
}