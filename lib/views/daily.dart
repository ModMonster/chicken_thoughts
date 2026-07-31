import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/reaction.dart';
import 'package:chicken_thoughts_notifications/data/share_manager.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/widgets/flying_sticker.dart';
import 'package:chicken_thoughts_notifications/widgets/reaction_picker_sheet.dart';
import 'package:chicken_thoughts_notifications/widgets/reaction_tooltip.dart';
import 'package:chicken_thoughts_notifications/widgets/streak_popup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class DailyView extends StatefulWidget {
  final ChickenThought chickenThought;
  final ValueNotifier currentPageNotifier;

  const DailyView({required this.chickenThought, required this.currentPageNotifier, super.key});

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  final GlobalKey chickenThoughtsImageKey = GlobalKey();
  List<Reaction> reactions = [];
  OverlayEntry? flyingSticker;
  OverlayEntry? tooltip;
  AnimationController? tooltipController;

  void addReaction(BuildContext context, Reaction reaction, Offset startPosition, Offset endPosition) {
    flyingSticker = OverlayEntry(
      builder: (_) {
        return FlyingSticker(
          start: startPosition,
          end: endPosition,
          emoji: reaction.emoji,
          onFinished: () {
            flyingSticker?.remove();
            flyingSticker = null;

            setState(() {
              reactions.add(reaction);
            });
          },
        );
      },
    );

    Overlay.of(context).insert(flyingSticker!);
  }

  void showReactionTooltip(Reaction reaction, Offset position) {
    tooltip?.remove();

    tooltip = OverlayEntry(
      builder: (context) {
        return ReactionTooltip(
          reaction,
          position: position,
          delete: () => deleteReaction(reaction),
          close: () {
            tooltip?.remove();
            tooltip = null;
          }
        );
      },
    );

    Overlay.of(context).insert(tooltip!);
  }

  void deleteReaction(Reaction reaction) {
    setState(() {
      reactions.remove(reaction);
    });
    tooltip?.remove();
    tooltip = null;
    DatabaseManager.deleteReaction(reaction);
  }

  @override
  void initState() {
    DatabaseManager.getReactions(widget.chickenThought.id).then((value) =>
      setState(() {
        reactions = value;
      })
    );

    // This prevents the reactions from all clumping in the top left on initial load.
    // Don't ask questions.
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chickenThought.displayName),
        actions: [
          if (MediaQuery.of(context).size.width <= 600) IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: Icon(Icons.settings),
            tooltip: "Settings",
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: StreamBuilder(
                          stream: Hive.box("settings").watch(key: "show_reactions"),
                          builder: (context, asyncSnapshot) {
                            return Stack(
                              children: [
                                Image.memory(
                                  widget.chickenThought.image,
                                  key: chickenThoughtsImageKey
                                ),
                            
                                ...reactions.map((reaction) {
                                  final renderBox = chickenThoughtsImageKey.currentContext!.findRenderObject() as RenderBox;
                            
                                  Offset pos = Offset(
                                    renderBox.size.width * reaction.position.dx - 18,
                                    renderBox.size.height * reaction.position.dy - 18
                                  );
                            
                                  return Positioned(
                                    left: pos.dx,
                                    top: pos.dy,
                                    child: AnimatedOpacity(
                                      opacity: Hive.box("settings").get("show_reactions", defaultValue: true)? 1.0 : 0.0,
                                      duration: Durations.short3,
                                      curve: Curves.easeOut,
                                      child: InkWell(
                                        onTap: () {
                                          if (Hive.box("settings").get("show_reactions", defaultValue: true)) {
                                            showReactionTooltip(reaction, renderBox.localToGlobal(Offset.zero) + pos);
                                          }
                                        },
                                        child: Text(
                                          reaction.emoji,
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }
                        )
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!kIsWeb) IconButton(
                        onPressed: () {
                          Vibrate.tap();
                          ShareManager.share(widget.chickenThought.id, displayName: widget.chickenThought.displayName);
                        },
                        tooltip: "Share",
                        icon: Icon(Icons.share),
                      ),
                      IconButton(
                        tooltip: Hive.box("settings").get("show_reactions", defaultValue: true)? "Hide reactions" : "Show reactions",
                        onPressed: () {
                          Hive.box("settings").put("show_reactions", !Hive.box("settings").get("show_reactions", defaultValue: true));
                        },
                        icon: Icon(Hive.box("settings").get("show_reactions", defaultValue: true)? Icons.visibility_outlined : Icons.visibility_off_outlined)
                      ),
                      if (Hive.box("settings").containsKey("user.id")) IconButton(
                        onPressed: () {
                          showModalBottomSheet(context: context, builder: (context) => ReactionPickerSheet(widget.chickenThought.id, chickenThoughtsImageKey, addReaction));
                        },
                        tooltip: "Add reaction",
                        icon: Icon(Icons.add_reaction),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          StreakPopup(onTap: () {
            widget.currentPageNotifier.value = 2;
          })
        ],
      )
    );
  }
}