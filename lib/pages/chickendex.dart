import 'package:chicken_thoughts_notifications/pages/chickendex_normal.dart';
import 'package:flutter/material.dart';

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