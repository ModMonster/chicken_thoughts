import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      print(results);
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.ethernet) || results.contains(ConnectivityResult.other)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, "/"));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ErrorFetching()
      ),
    );
  }
}