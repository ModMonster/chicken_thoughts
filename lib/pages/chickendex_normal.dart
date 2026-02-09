import 'package:chicken_thoughts_notifications/widgets/chickendex_locked.dart';
import 'package:flutter/material.dart';

class ChickendexNormalView extends StatelessWidget {
  const ChickendexNormalView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: 300,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8
      ),
      itemBuilder: (context, index) {
        return ChickendexLocked(index);
      }
    );
  }
}