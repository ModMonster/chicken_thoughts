import 'dart:async';

import 'package:flutter/material.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';
import 'package:totp/totp.dart';

const String theCrabSecret = "U5JWKZG6U7XGU2PH7S4XRQLMCWRXKTQS";

class SettingsDeveloperTotpDialog extends StatefulWidget {
  const SettingsDeveloperTotpDialog({super.key});

  @override
  State<SettingsDeveloperTotpDialog> createState() => _SettingsDeveloperTotpDialogState();
}

class _SettingsDeveloperTotpDialogState extends State<SettingsDeveloperTotpDialog> {
  final TextEditingController _totpController = TextEditingController();
  final Totp _totp = Totp.fromBase32(
    secret: theCrabSecret,
    digits: 6,
    algorithm: Algorithm.sha1,
    period: 30
  );
  late final Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        setState(() {});
      }
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Developer options"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _totpController,
            autofocus: true,
            decoration: InputDecoration(
              label: Text("Enter time-based key"),
              border: InputBorder.none,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(
              end: 1 - _totp.remaining / _totp.period
            ),
            duration: Duration(seconds: 1),
            builder: (context, value, child) {
              return LinearProgressIndicatorM3E(
                size: LinearProgressM3ESize.s,
                shape: ProgressM3EShape.flat,
                value: value,
                activeColor: value < 0.2? Theme.of(context).colorScheme.error : null,
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel")
        ),
        TextButton(
          onPressed: () {
            if (_totp.now() == _totpController.text) {
              Navigator.pushReplacementNamed(context, "/settings/dev");
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Incorrect key."),
                  behavior: SnackBarBehavior.floating,
                )
              );
            }
          },
          child: Text("OK")
        )
      ],
    );
  }
}