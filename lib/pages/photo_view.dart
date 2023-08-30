import 'package:cached_network_image/cached_network_image.dart';
import 'package:chicken_thoughts_notifications/pages/history.dart';
import 'package:chicken_thoughts_notifications/widgets/error_fetching.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({Key? key, required this.currentChickyThought, required this.pastChickyThoughts, this.heroTag, this.initialPage = 0}) : super(key: key);

  final ChickenThoughtDate currentChickyThought;
  final List<ChickenThoughtDate> pastChickyThoughts;
  final Object? heroTag;
  final int initialPage;

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  late final PageController pageController;
  late ChickenThoughtDate activeChickenThought;
  late final List<ChickenThoughtDate> chickyThoughts;

  @override
  void initState() {
    chickyThoughts = widget.pastChickyThoughts..insert(0, widget.currentChickyThought);
    activeChickenThought = chickyThoughts[widget.initialPage];

    pageController = PageController(
      initialPage: widget.initialPage
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 4,
        title: ListTile(
          title: Text("Chicken Thought #${activeChickenThought.number}"),
          subtitle: Text(activeChickenThought.dateShown),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      body: PhotoViewGallery.builder(
        onPageChanged: (index) {
          setState(() {
            activeChickenThought = chickyThoughts[pageController.page!.round().toInt()];
          });
        },
        pageController: pageController,
        backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions.customChild(
            child: CachedNetworkImage(imageUrl: chickyThoughts[index].url, errorWidget: (context, idk, progress) => ErrorFetching()),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.8,
            heroAttributes: index == widget.initialPage? widget.heroTag == null? null :
              PhotoViewHeroAttributes(
                tag: widget.heroTag!,
                transitionOnUserGestures: true,
              ) : null,
          );
        },
        itemCount: 8,
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
              ? null
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!
          ),
        ),
      ),
    );
  }
}