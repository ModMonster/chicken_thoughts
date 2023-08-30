// import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chicken_thoughts_notifications/main.dart';
// import 'package:flutter/material.dart';

// class ChickenThoughtDate {
//   String dateShown;
//   String url;
//   int number;

//   ChickenThoughtDate({required this.dateShown, required this.url, required this.number});
// }

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({required this.onRefresh, required this.chickyMap, Key? key}) : super(key: key);

//   final Map<String, String> chickyMap;
//   final void Function() onRefresh;

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   int currentChickyThought = 0;
//   CarouselController carouselController = CarouselController();
//   List<ChickenThoughtDate> pastChickyThoughts = [];

//   @override
//   void initState() {
//     getImageList();
//     super.initState();
//   }

//   void getImageList() {
//     for (var i = 1; i < 8; i++) {
//       int number = Random((DateTime.now().millisecondsSinceEpoch / 86400000).floor() - i).nextInt(507);
      
//       pastChickyThoughts.add(ChickenThoughtDate(
//         dateShown: i == 1? "Yesterday" : "$i days ago",
//         url: widget.chickyMap[number.toString()]!,
//         number: number
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text("History"),
//       //   actions: [
//       //     IconButton(
//       //       onPressed: widget.onRefresh,
//       //       icon: Icon(Icons.refresh),
//       //       tooltip: "Refresh",
//       //     ),
//       //     IconButton(
//       //       onPressed: () {
//       //         showAboutDialog(
//       //           context: context,
//       //           applicationVersion: version,
//       //           applicationIcon: CircleAvatar(backgroundImage: AssetImage("assets/icon.png")),
//       //           children: [
//       //             Text("An app that sends you a new Chicken Thought every day!")
//       //           ]
//       //         );
//       //       },
//       //       icon: Icon(Icons.info_outline),
//       //       tooltip: "Information",
//       //     )
//       //   ],
//       // ),
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar.large(
//             title: const Text("History"),
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 CarouselSlider(
//                   carouselController: carouselController,
//                   options: CarouselOptions(
//                     enableInfiniteScroll: false,
//                     enlargeCenterPage: true,
//                     onPageChanged: (index, reason) {
//                       setState(() {
//                         currentChickyThought = index;
//                       });
//                     },
//                     aspectRatio: 1
//                   ),
//                   items: [0, 1, 2, 3, 4, 5, 6].map((i) {
//                     return Builder(builder: (context) {
//                       return CachedNetworkImage(
//                         imageUrl: pastChickyThoughts[i].url,
//                         progressIndicatorBuilder: (context, url, progress) {
//                           return Center(child: CircularProgressIndicator(value: progress.progress));
//                         },
//                       );
//                     });
//                   }).toList(),
//                 ),
//                 Text("${pastChickyThoughts[currentChickyThought].dateShown} (#${pastChickyThoughts[currentChickyThought].number})"),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: pastChickyThoughts.map((i) {
//                     return GestureDetector(
//                       onTap: () {
//                         carouselController.animateToPage(pastChickyThoughts.indexOf(i));
//                       },
//                       child: Container(
//                         width: 12,
//                         height: 12,
//                         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: currentChickyThought == pastChickyThoughts.indexOf(i)? Colors.purple : Colors.grey
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 )
//               ],
//             ),
//           ),
//         ],
//       )
//     );
//   }
// }