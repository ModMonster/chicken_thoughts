import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_grid_image.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class ChickendexView extends StatefulWidget {
  const ChickendexView({super.key});

  @override
  State<ChickendexView> createState() => _ChickendexViewState();
}

class _ChickendexViewState extends State<ChickendexView> {
  late final Future<Season> _future;

  @override
  void initState() {
    _future = DatabaseManager.getDefaultSeason();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("chickendex");

    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator()
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text("Chickendex"),
                pinned: true,
                snap: true,
                floating: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChickendexImageExpandedPage()));
                        },
                        icon: Icon(Icons.view_array),
                        label: Text("View unlocked (${box.length}/${snapshot.data!.imageCount})"),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid.builder(
                  itemCount: snapshot.data!.imageCount,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 96,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8
                  ),
                  itemBuilder: (context, inp) {
                    int index = inp + 1;
          
                    // We haven't seen it yet; locked!
                    if (box.get(index.toString(), defaultValue: 0) == 0) {
                      return ChickendexLocked(index);
                    }
                    
                    // We have seen it; show it!
                    return ChickendexGridImage(index.toString());
                  }
                )
              )
            ]
          );
        }
      ),
    );
  }
}