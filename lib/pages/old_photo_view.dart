// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:photo_view/photo_view.dart';

// class PhotoViewPage extends StatelessWidget {
//   const PhotoViewPage({Key? key, required this.imageProvider, this.heroTag}) : super(key: key);

//   final ImageProvider imageProvider;
//   final Object? heroTag;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle(
//           statusBarBrightness: Theme.of(context).brightness
//         ),
//       ),
//       body: PhotoView(
//         backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
//         imageProvider: imageProvider,
//         minScale: PhotoViewComputedScale.contained * 0.8,
//         maxScale: PhotoViewComputedScale.covered * 1.8,
//         heroAttributes: heroTag == null? null : const PhotoViewHeroAttributes(
//           tag: "mainChicken",
//           transitionOnUserGestures: true,
//         ),
//         loadingBuilder: (context, event) => Center(
//           child: CircularProgressIndicator(
//             value: event == null
//               ? null
//               : event.cumulativeBytesLoaded / event.expectedTotalBytes!
//           ),
//         ),
//       ),
//     );
//   }
// }