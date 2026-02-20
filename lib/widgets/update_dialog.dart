import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

class UpdateDialog extends StatefulWidget {
  final bool required;
  const UpdateDialog({this.required = false, super.key});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
    });

    // Fake progress
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 30));
      setState(() => _downloadProgress = i / 100);
    }

    setState(() {
      _isDownloading = false;
      _downloadProgress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDownloading && !widget.required,
      child: AlertDialog(
        title: Text("Update ${widget.required? "required" : "available"}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(widget.required?
                "This app version is no longer supported." :
                "A new update is available!"),
            ),
            Row(
              children: [
                if (!widget.required) AnimatedContainer(
                  duration: Durations.long2,
                  curve: Curves.easeInOutCubic,
                  width: _isDownloading? 0 : 90,
                  child: AnimatedOpacity(
                    duration: Durations.long2,
                    curve: Curves.easeInOutCubic,
                    opacity: _isDownloading? 0.0 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OutlinedButton(
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          height: 20,
                          child: Text(
                            "Skip",
                            overflow: TextOverflow.clip,
                          )
                        ),
                        onPressed: () {
                          Vibrate.tap();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: _isDownloading? null : () {
                      Vibrate.tap();
                      _startDownload();
                    },
                    child: AnimatedSwitcher(
                      duration: Durations.long2,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: _isDownloading? LinearProgressIndicatorM3E(
                        value: _downloadProgress,
                        inset: 0,
                      ) : const Text("Download")
                    ),
                  ),
                ),
              ],
            )
          ]
        ),
      )
    );
  }
}