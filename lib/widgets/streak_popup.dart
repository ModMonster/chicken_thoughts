import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class StreakPopup extends StatefulWidget {
  final void Function() onTap;
  const StreakPopup({required this.onTap, super.key});

  @override
  State<StreakPopup> createState() => _StreakPopupState();
}

class _StreakPopupState extends State<StreakPopup> {
  bool _visible = false;
  int _streakCounterValue = 0;
  IconData _icon = Icons.local_fire_department_outlined;
  
  Future<void> _doAnimation() async {
    if (!Hive.box("settings").get("streak.animate", defaultValue: false)) return;
    Hive.box("settings").put("streak.animate", false);

    _streakCounterValue = Hive.box("settings").get("streak", defaultValue: 0) - 1;
    if (_streakCounterValue < 0) return;

    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _visible = true;
    });
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _streakCounterValue += 1;
      _icon = Icons.local_fire_department;
    });
    await Future.delayed(Duration(seconds: 4));
    if (!mounted) return;
    setState(() {
      _visible = false;
    });
  }

  @override
  void initState() {
    Hive.box("settings").watch().where((event) => {"streak.animate"}.contains(event.key)).listen((event) {
      _doAnimation();
    });
    _doAnimation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 16,
      child: AnimatedSwitcher(
        duration: Durations.medium2,
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child
            ),
          );
        },
        child: Visibility(
          key: ValueKey(_visible),
          visible: _visible,
          child: Material(
            borderRadius: BorderRadius.circular(999),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Center(
                  child: Row(
                    spacing: 4.0,
                    children: [
                      AnimatedFlipCounter(
                        duration: Durations.extralong1,
                        curve: Curves.easeInOutCubic,
                        value: _streakCounterValue,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: Durations.medium4,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Icon(
                          _icon,
                          key: ValueKey(_icon),
                        )
                      )
                    ],
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}