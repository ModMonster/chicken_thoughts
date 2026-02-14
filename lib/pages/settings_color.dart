import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

final List<SettingsColor> colors = [
  SettingsColor("Based on wallpaper", Colors.black),
  SettingsColor("Red", Colors.red),
  SettingsColor("Pink", Colors.pink),
  SettingsColor("Purple", Colors.purple),
  SettingsColor("Deep purple", Colors.deepPurple),
  SettingsColor("Indigo", Colors.indigo),
  SettingsColor("Blue", Colors.blue),
  SettingsColor("Light blue", Colors.lightBlue),
  SettingsColor("Cyan", Colors.cyan),
  SettingsColor("Teal", Colors.teal),
  SettingsColor("Green", Colors.green),
  SettingsColor("Light green", Colors.lightGreen),
  SettingsColor("Lime", Colors.lime),
  SettingsColor("Yellow", Colors.yellow),
  SettingsColor("Amber", Colors.amber),
  SettingsColor("Orange", Colors.orange),
  SettingsColor("Deep orange", Colors.deepOrange),
  SettingsColor("Brown", Colors.brown),
  SettingsColor("Grey", Colors.grey),
  SettingsColor("Blue grey", Colors.blueGrey)
];

class SettingsColorPage extends StatelessWidget {
  final bool hasDynamicColor;
  const SettingsColorPage({required this.hasDynamicColor, super.key});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box("settings");
    int groupValue = box.get("color", defaultValue: hasDynamicColor? 0 : 3);

    return Scaffold(
      body: RadioGroup(
        groupValue: groupValue,
        onChanged: (value) {
          box.put("color", value);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("Choose primary color"),
            ),
            SliverSafeArea(
              bottom: true,
              top: false,
              sliver: SliverList.builder(
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    if (!hasDynamicColor) return Container();
                    return RadioListTile(
                      value: index,
                      controlAffinity: ListTileControlAffinity.trailing,
                      secondary: CircleAvatar(
                        child: Icon(Icons.palette_outlined)
                      ),
                      title: Text("Based on wallpaper"),
                      subtitle: Text("Requires Android 12+"),
                    );
                  }
                  
                  SettingsColor color = colors[index];
                  return RadioListTile(
                    value: index,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: CircleAvatar(
                      backgroundColor: color.color,
                    ),
                    title: Text(color.name)
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsColor {
  String name;
  Color color;

  SettingsColor(this.name, this.color);
}