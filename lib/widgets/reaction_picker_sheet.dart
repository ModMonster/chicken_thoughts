import 'package:chicken_thoughts_notifications/data/reaction.dart';
import 'package:chicken_thoughts_notifications/widgets/reaction_placement_overlay.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class ReactionPickerSheet extends StatelessWidget {
  final GlobalKey chickenThoughtsImageKey;
  final String chickenThoughtId;
  final void Function(BuildContext context, Reaction reaction, Offset startPosition, Offset endPosition) onPlaced;
  const ReactionPickerSheet(this.chickenThoughtId, this.chickenThoughtsImageKey, this.onPlaced, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            child: Row(
              children: [
                Text(
                  "Choose reaction",
                  style: Theme.of(context).textTheme.headlineMedium
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)
                )
              ],
            ),
          ),
          Expanded(
            child: EmojiPicker(
              config: Config(
                viewOrderConfig: ViewOrderConfig(
                  bottom: EmojiPickerItem.categoryBar,
                  middle: EmojiPickerItem.emojiView,
                  top: EmojiPickerItem.searchBar
                ),
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  columns: 7,
                  emojiSizeMax: 36.0
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  backgroundColor: Colors.transparent,
                  showSearchViewButton: false,
                  showBackspaceButton: false
                ),
                categoryViewConfig: CategoryViewConfig(
                  backgroundColor: Colors.transparent,
                  recentTabBehavior: RecentTabBehavior.NONE,
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  iconColorSelected: Theme.of(context).colorScheme.primary,
                  dividerColor: Colors.transparent,
                  backspaceColor: Colors.transparent,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                )
              ),
              onEmojiSelected: (category, emoji) async {
                Hive.box("settings").put("show_reactions", true);
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.transparent,
                    pageBuilder: (context, animation, secondaryAnimation) => ReactionPlacementOverlay(
                      chickenThoughtsImageKey: chickenThoughtsImageKey,
                      emoji: emoji,
                      chickenThoughtId: chickenThoughtId,
                      onPlaced: onPlaced
                    ),
                    transitionsBuilder:(context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  )
                );
              },
            )
          )
        ],
      ),
    );
  }
}