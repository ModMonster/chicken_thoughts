import 'package:cached_network_image/cached_network_image.dart';
import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingImage extends StatelessWidget {
  const LoadingImage(this.url, {Key? key}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      progressIndicatorBuilder: (context, idk, progress) {
        if (!kIsWeb) {
          // mobile version
          return Lottie.asset("assets/loader.json");
        } else {
          // web version
          return Center(child: CircularProgressIndicator());
        }
      },
      errorWidget: (context, idk, progress) => ErrorFetching()
    );
  }
}