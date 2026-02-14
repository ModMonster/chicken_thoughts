import 'dart:math' as math;

import 'package:flutter/material.dart';

// class ChickendexPage extends StatefulWidget {
//   const ChickendexPage({required this.chickyMap, super.key});

//   final Map<String, String> chickyMap;

//   @override
//   State<ChickendexPage> createState() => _ChickendexPageState();
// }

// class _ChickendexPageState extends State<ChickendexPage> {
//   ChickendexViews selection = ChickendexViews.normal;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Widget buildView() {
//     switch (selection) {
//       case ChickendexViews.normal:
//         return ChickendexNormalView();
//       case ChickendexViews.special:
//         return ChickendexNormalView();
//       case ChickendexViews.unlocked:
//         return ChickendexNormalView();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         SliverAppBar(
//           title: const Text("Chickendex"),
//           pinned: true,
//           snap: true,
//           floating: true,
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(56),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: SegmentedButton(
//                   segments: [
//                     ButtonSegment(
//                       value: ChickendexViews.normal,
//                       label: Text("Normal")
//                     ),
//                     ButtonSegment(
//                       value: ChickendexViews.special,
//                       label: Text("Holiday")
//                     ),
//                     ButtonSegment(
//                       value: ChickendexViews.unlocked,
//                       label: Text("Unlocked")
//                     ),
//                   ],
//                   selected: {selection},
//                   onSelectionChanged: (newSelection) {
//                     setState(() {
//                       selection = newSelection.first;
//                     });
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.all(8.0),
//           sliver: buildView()
//         )
//       ],
//     );
//   }
// }

// enum ChickendexViews {
//   normal,
//   special,
//   unlocked
// }

class ChickendexPage extends StatelessWidget {
  const ChickendexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          transform: GradientRotation(math.pi / 4 + math.pi / 8),
          colors: [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple
          ]
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Chickendex"),
          backgroundColor: Colors.transparent,
        ),
        body: Transform.rotate(
          angle: -math.pi / 8,
          child: Center(
            child: Text(
              "COMING SOON!",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          )
        ),
      ),
    );
  }
}