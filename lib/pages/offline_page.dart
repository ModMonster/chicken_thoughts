import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ErrorFetching()
      ),
    );
  }
}