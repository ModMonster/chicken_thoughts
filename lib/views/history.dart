import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String formatDate(DateTime date, int index) {
    if (index == 0) {
      return "Yesterday";
    } else if (index < 6) {
      // Show weekday
      return DateFormat("EEEE").format(date);
    } else if (date.year == 2026) {
      // Show day, month
      return DateFormat("MMMM d").format(date);
    } else {
      // Show day, month, year
      return DateFormat("MMMM d, yyyy").format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text("History"),
          actions: [
            if (MediaQuery.of(context).size.width <= 600) IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/settings");
              },
              icon: Icon(Icons.settings),
              tooltip: "Settings",
            )
          ],
        ),
        SliverSafeArea(
          top: false,
          bottom: true,
          left: true,
          right: false,
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width <= 600? 600 : 400,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75
            ),
            itemBuilder: (context, index) {
              DateTime day = now.subtract(Duration(days: index + 1));

              return FutureBuilder(
                future: DatabaseManager.getChickenThoughtOnDate(day),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(formatDate(day, index)),
                          subtitle: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Shimmer(
                                    child: Container(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 13,
                                      width: 150,
                                    ),
                                  ),
                                ),
                              ),
                              Spacer()
                            ],
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Shimmer(
                                child: Container(
                                  color: Theme.of(context).colorScheme.onInverseSurface,
                                )
                              ),
                            )
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(formatDate(day, index)),
                        subtitle: Text(snapshot.data!.displayName),
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: PhotoViewGallery.builder(
                                backgroundDecoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                                itemCount: snapshot.data!.images.length,
                                builder: (context, index) {
                                  return PhotoViewGalleryPageOptions(
                                    maxScale: PhotoViewComputedScale.contained,
                                    minScale: PhotoViewComputedScale.contained,
                                    imageProvider: MemoryImage(snapshot.data!.images[index])
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              );
            },
          ),
        )
      ],
    );
  }
}