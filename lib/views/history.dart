import 'package:chicken_thoughts_notifications/views/coming_soon.dart';
import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  // List<ChickenThoughtDate> pastChickyThoughts = [];

  // @override
  // void initState() {
  //   pastChickyThoughts = ChickenThoughtDate.getImageList(widget.chickyMap);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return ComingSoonView("History");
    // return CustomScrollView(
    //   slivers: [
    //     SliverAppBar.large(
    //       title: const Text("History"),
    //     ),
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //         (context, i) {
    //           double width = MediaQuery.of(context).size.width;
    //           double horizontalPadding = 8;

    //           if (width > 720) {
    //             horizontalPadding = (width - 720) / 2;
    //           }

    //           return Padding(
    //             padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
    //             child: Card(
    //               elevation: 0,
    //               child: Column(
    //                 children: [
    //                   ListTile(
    //                     title: Text("Chicken Thought #${pastChickyThoughts[i].number}"),
    //                     subtitle: Text(pastChickyThoughts[i].dateShown),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(8),
    //                       child: Material(
    //                         child: InkWell(
    //                           onTap: () {
    //                             Navigator.push(context, MaterialPageRoute(builder: (context) {
    //                               int chickyNumber = ChickenThoughtDate.getCurrentChickyNumber();

    //                               return PhotoViewPage(
    //                                 currentChickyThought: ChickenThoughtDate(
    //                                   dateShown: "Current",
    //                                   url: widget.chickyMap[chickyNumber.toString()]!,
    //                                   number: chickyNumber
    //                                 ),
    //                                 pastChickyThoughts: ChickenThoughtDate.getImageList(widget.chickyMap),
    //                                 heroTag: "chicken$i",
    //                                 initialPage: i + 1,
    //                               );
    //                             }));
    //                           },
    //                           child: Hero(
    //                             tag: "chicken$i",
    //                             child: CachedNetworkImage(
    //                               errorWidget: (context, idk, progress) => ErrorFetching(),
    //                               imageUrl: pastChickyThoughts[i].url,
    //                               progressIndicatorBuilder: (context, url, progress) {
    //                                 return AspectRatio(
    //                                   aspectRatio: 1,
    //                                   child: Shimmer.fromColors(
    //                                     baseColor: Colors.grey[300]!,
    //                                     highlightColor: Colors.grey[100]!,
    //                                     child: Container(color: Colors.white)
    //                                   ),
    //                                 );
    //                               },
    //                             ),
    //                           )
    //                         ),
    //                       )
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           );
    //         },
    //         childCount: 7
    //       ),
    //     ),
    //   ],
    // );
  }
}