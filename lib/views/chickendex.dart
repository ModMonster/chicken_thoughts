import 'package:chicken_thoughts_notifications/pages/chickendex_image_expanded.dart';
import 'package:chicken_thoughts_notifications/views/chickendex_normal.dart';
import 'package:flutter/material.dart';

class ChickendexView extends StatefulWidget {
  const ChickendexView({super.key});

  @override
  State<ChickendexView> createState() => _ChickendexViewState();
}

class _ChickendexViewState extends State<ChickendexView> {
  ChickendexViews selection = ChickendexViews.normal;

  @override
  void initState() {
    super.initState();
  }

  Widget buildView() {
    switch (selection) {
      case ChickendexViews.normal:
        return ChickendexNormalView();
      case ChickendexViews.special:
        return ChickendexNormalView();
      case ChickendexViews.unlocked:
        return ChickendexNormalView();
    }
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChickendexImageExpandedPage()));
                },
                icon: Icon(Icons.view_array),
                label: Text("View unlocked"),
              ),
            )
          ],
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
                      label: Text("Special"),
                      enabled: false
                    ),
                    ButtonSegment(
                      value: ChickendexViews.unlocked,
                      label: Text("Unlocked"),
                      enabled: false
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
          sliver: buildView()
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