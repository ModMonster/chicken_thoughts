import 'package:chicken_thoughts_notifications/data/loose_scroll_physics.dart';
import 'package:chicken_thoughts_notifications/data/vibrate.dart';
import 'package:flutter/material.dart';

class SettingsUserDialog extends StatefulWidget {
  const SettingsUserDialog({super.key});

  @override
  State<SettingsUserDialog> createState() => _SettingsUserDialogState();
}

class _SettingsUserDialogState extends State<SettingsUserDialog> {
  final List<String> emojis = [
    "😵‍💫", "🥺", "🤯", "😎", "🫪", "🫧", "🔥", "🪨", "👹","🐱", "🐶", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",  "🦁", "🐮", "🐷", "🐸", "🐵", "🐧", "🐥", "🦆", "🦉", "🦄", "🐝", "🦋", "🐙", "🦑", "🐢", "🦖", "🦕", "🐳", "🐬", "🦈", "🐺", "🦝", "🦫", "🦦", "🦥", "🐿️", "🦔", "🐞", "🕷️", "🤖", "👽", "👻", "💀", "☠️", "🤡", "🗿", "👾", "👺", "🧌", "🧙", "🧛", "🧟", "🧚", "🧜", "🦸", "🦹", "🍕", "🍔", "🍟", "🍩", "🍪", "🍓", "🍉", "🌮", "🌭", "🍣", "🧁", "🍫", "🍿", "🥨", "🥑", "🌶️", "🎮", "🎲", "🧩", "🎨", "🎸", "🎧", "📚", "✏️", "🖌️", "💻", "📱", "📷", "🎥", "🕹️", "🚀", "🛸", "🚗", "🚲", "🛹", "🛼", "⚽", "🏀", "🎯", "⭐", "🌈", "🌙", "☀️", "⚡", "❄️", "🌊", "🌋", "💎", "🪐", "🌌", "🌵", "🌻", "🌹", "🍀", "🤓", "🥳", "🤠", "🤔", "😈", "🥶", "🥸", "😂", "😭", "😴", "🤪", "😜", "🤩", "🥰", "🧃", "🧸", "🪴", "🛏️", "🪑", "🕶️", "🎩", "👑", "🧢", "👟", "🧤", "🧦", "🧹", "🪄", "🧪"
  ];
  
  final List<Color> colors = [
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

  final TextEditingController controller = TextEditingController(text: "Maddie");
  PageController? foregroundController;
  PageController? backgroundController;
  int selectedForegroundIndex = 0;
  int selectedBackgroundIndex = 0;
  EditMode mode = EditMode.none;

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

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors[selectedBackgroundIndex],
          brightness: Theme.of(context).brightness
        )
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              child: Column(
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
                                child: mode == EditMode.background? SizedBox(
                                  key: const ValueKey("bg-edit"),
                                  height: 144,
                                  child: PageView.builder(
                                    physics: LooseScrollPhysics(),
                                    pageSnapping: false,
                                    controller: backgroundController,
                                    itemCount: colors.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        selectedBackgroundIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors[index],
                                        ),
                                        width: 144,
                                        height: 144,
                                      );
                                    },
                                  ),
                                ) : IgnorePointer(
                                  child: Container(
                                    key: const ValueKey("bg-normal"),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors[selectedBackgroundIndex],
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
                                child: mode == EditMode.foreground? SizedBox(
                                  height: 90,
                                  child: PageView.builder(
                                    physics: LooseScrollPhysics(),
                                    pageSnapping: false,
                                    controller: foregroundController,
                                    itemCount: emojis.length,
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
                                            emojis[index],
                                            style: const TextStyle(
                                              fontSize: 66
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ) : IgnorePointer(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      emojis[selectedForegroundIndex],
                                      style: TextStyle(
                                        fontSize: 66
                                      ),
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
                                    emojis[selectedForegroundIndex],
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
                                color: colors[selectedBackgroundIndex],
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
                    padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
                    child: ListTile(
                      leading: Icon(Icons.logout_outlined),
                      title: Text("Log out"),
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {},
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

enum EditMode {
  none,
  foreground,
  background;
}