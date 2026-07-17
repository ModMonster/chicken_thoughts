import 'package:chicken_thoughts_notifications/data/loose_scroll_physics.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

final List<String> userEmojis = [
  "😵‍💫", "🥺", "🤯", "😎", "🫪", "🫧", "🔥", "🪨", "👹","🐱", "🐶", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",  "🦁", "🐮", "🐷", "🐸", "🐵", "🐧", "🐥", "🦆", "🦉", "🦄", "🐝", "🦋", "🐙", "🦑", "🐢", "🦖", "🦕", "🐳", "🐬", "🦈", "🐺", "🦝", "🦫", "🦦", "🦥", "🐿️", "🦔", "🐞", "🕷️", "🤖", "👽", "👻", "💀", "☠️", "🤡", "🗿", "👾", "👺", "🧌", "🧙", "🧛", "🧟", "🧚", "🧜", "🦸", "🦹", "🍕", "🍔", "🍟", "🍩", "🍪", "🍓", "🍉", "🌮", "🌭", "🍣", "🧁", "🍫", "🍿", "🥨", "🥑", "🌶️", "🎮", "🎲", "🧩", "🎨", "🎸", "🎧", "📚", "✏️", "🖌️", "💻", "📱", "📷", "🎥", "🕹️", "🚀", "🛸", "🚗", "🚲", "🛹", "🛼", "⚽", "🏀", "🎯", "⭐", "🌈", "🌙", "☀️", "⚡", "❄️", "🌊", "🌋", "💎", "🪐", "🌌", "🌵", "🌻", "🌹", "🍀", "🤓", "🥳", "🤠", "🤔", "😈", "🥶", "🥸", "😂", "😭", "😴", "🤪", "😜", "🤩", "🥰", "🧃", "🧸", "🪴", "🛏️", "🪑", "🕶️", "🎩", "👑", "🧢", "👟", "🧤", "🧦", "🧹", "🪄", "🧪"
];

final List<Color> userColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.blueGrey,
  Color(0xFFC2B7F0),
  Color(0xFF294A40),
  Color(0xFFF29BE5),
  Color(0xFF585E6B)
];

class SettingsUserDialog extends StatefulWidget {
  const SettingsUserDialog({super.key});

  @override
  State<SettingsUserDialog> createState() => _SettingsUserDialogState();
}

class _SettingsUserDialogState extends State<SettingsUserDialog> {
  late final TextEditingController controller;
  PageController? foregroundController;
  PageController? backgroundController;
  late int selectedForegroundIndex;
  late int selectedBackgroundIndex;
  EditMode mode = EditMode.none;

  @override
  void initState() {
    super.initState();
    Box settings = Hive.box("settings");
    controller = TextEditingController(text: settings.get("user.name"));
    selectedForegroundIndex = settings.get("user.emoji");
    selectedBackgroundIndex = settings.get("user.color");
  }

  @override
  Widget build(BuildContext context) {
    foregroundController = PageController(
      viewportFraction: 136 / MediaQuery.of(context).size.width,
      initialPage: selectedForegroundIndex
    );

    backgroundController = PageController(
      viewportFraction: 168 / MediaQuery.of(context).size.width,
      initialPage: selectedBackgroundIndex
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) { 
        Box settings = Hive.box("settings");
        if (!settings.containsKey("user.id")) return;

        settings.put("user.name", controller.text);
        settings.put("user.emoji", selectedForegroundIndex);
        settings.put("user.color", selectedBackgroundIndex);

        DatabaseManager.updateUser(settings.get("user.id"), controller.text, selectedForegroundIndex, selectedBackgroundIndex);
      },
      child: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: userColors[selectedBackgroundIndex],
            brightness: Theme.of(context).brightness
          )
        ),
        child: Builder(
          builder: (context) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                    child: TextField(
                      controller: controller,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 48, 0, 24),
                        child: Stack(
                          children: [
                            Center(
                              child: AnimatedSwitcher(
                                duration: Durations.short4,
                                child: mode == EditMode.background? PageView.builder(
                                  key: const ValueKey("bg-edit"),
                                  physics: LooseScrollPhysics(),
                                  pageSnapping: false,
                                  controller: backgroundController,
                                  itemCount: userColors.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      selectedBackgroundIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: userColors[index],
                                        ),
                                      ),
                                    );
                                  },
                                ) : IgnorePointer(
                                  key: const ValueKey("bg-normal"),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: userColors[selectedBackgroundIndex],
                                    ),
                                    width: 144,
                                    height: 144,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: AnimatedSwitcher(
                                duration: Durations.short4,
                                child: mode == EditMode.foreground? PageView.builder(
                                  key: const ValueKey("fg-edit"),
                                  physics: LooseScrollPhysics(),
                                  pageSnapping: false,
                                  controller: foregroundController,
                                  itemCount: userEmojis.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      selectedForegroundIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return AnimatedOpacity(
                                      opacity: index == selectedForegroundIndex? 1 : 0.6,
                                      duration: Durations.short4,
                                      child: Center(
                                        child: Text(
                                          userEmojis[index],
                                          style: const TextStyle(
                                            fontSize: 66
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ) : IgnorePointer(
                                  key: const ValueKey("fg-normal"),
                                  child: Text(
                                    userEmojis[selectedForegroundIndex],
                                    style: TextStyle(
                                      fontSize: 66
                                    ),
                                  ),
                                ),
                              ),
                            ) 
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 32.0,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                if (mode != EditMode.foreground) Vibrate.tap();
                                setState(() {
                                  mode = EditMode.foreground;
                                });
                              },
                              child: AnimatedContainer(
                                width: 96,
                                height: 96,
                                duration: Durations.short2,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: mode == EditMode.foreground? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                                    width: mode == EditMode.foreground? 4.0 : 1.0
                                  ),
                                  borderRadius: BorderRadius.circular(24)
                                ),
                                child: Center(
                                  child: Text(
                                    userEmojis[selectedForegroundIndex],
                                    style: TextStyle(
                                      fontSize: 48
                                    )
                                  )
                                )
                              ),
                            ),
                          ),
                          Text("Foreground")
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: AnimatedContainer(
                              width: 96,
                              height: 96,
                              duration: Durations.short2,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: mode == EditMode.background? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                                  width: mode == EditMode.background? 4.0 : 1.0
                                ),
                                color: userColors[selectedBackgroundIndex],
                                borderRadius: BorderRadius.circular(24)
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (mode != EditMode.background) Vibrate.tap();
                                    setState(() {
                                      mode = EditMode.background;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text("Background")
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 36.0, top: 24.0),
                    child: ListTile(
                      leading: Icon(Icons.logout_outlined),
                      title: Text("Log out"),
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            title: Text("Log out"),
                            content: Text("Are you sure you want to log out?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel")
                              ),
                              TextButton(
                                onPressed: () {
                                  Hive.box("settings").delete("user.id");
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text("OK")
                              )
                            ],
                          );
                        });
                      },
                    ),
                  )
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

enum EditMode {
  none,
  foreground,
  background;
}