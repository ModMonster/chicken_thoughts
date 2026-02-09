import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chicken_thoughts_notifications/main.dart';
import 'package:chicken_thoughts_notifications/pages/history.dart';
import 'package:chicken_thoughts_notifications/pages/photo_view.dart';
import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChickendexPage extends StatefulWidget {
  const ChickendexPage({required this.chickyMap, Key? key}) : super(key: key);

  final Map<String, String> chickyMap;

  @override
  State<ChickendexPage> createState() => _ChickendexPageState();
}

class _ChickendexPageState extends State<ChickendexPage> {
  ChickendexViews selection = ChickendexViews.normal;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text("Chickendex"),
          pinned: true,
          snap: true,
          floating: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton(
                  segments: [
                    ButtonSegment(
                      value: ChickendexViews.normal,
                      label: Text("Normal")
                    ),
                    ButtonSegment(
                      value: ChickendexViews.special,
                      label: Text("Holiday")
                    ),
                    ButtonSegment(
                      value: ChickendexViews.unlocked,
                      label: Text("Unlocked")
                    ),
                  ],
                  selected: {selection},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      selection = newSelection.first;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid.builder(
            itemCount: 300,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 100,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8
            ),
            itemBuilder: (context, index) {
              return ChickendexLocked(index);
            }
          ),
        )
      ],
    );
  }
}

enum ChickendexViews {
  normal,
  special,
  unlocked
}