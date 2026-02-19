import 'package:chicken_thoughts_notifications/data/notification_manager.dart';
import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:chicken_thoughts_notifications/pages/home.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/offline_page.dart';
import 'package:chicken_thoughts_notifications/pages/settings.dart';
import 'package:chicken_thoughts_notifications/pages/settings_caching.dart';
import 'package:chicken_thoughts_notifications/pages/settings_color.dart';
import 'package:chicken_thoughts_notifications/pages/settings_notifications.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

// This will be checked against the database when app starts
// It can be used to prompt updates and lock out old versions of the app
int versionCode = 5;
String version = "2.1.0";
String githubUrl = "https://github.com/modmonster/chicken_thoughts";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseManager.init();
  CacheManager.init();
  await Hive.initFlutter();
  await Hive.openBox("settings");
  await Hive.openBox("chickendex");
  if (!kIsWeb) await NotificationManager.initNotifications();

  runApp(ChickenThoughtsApp());
}

class ChickenThoughtsApp extends StatelessWidget {
  const ChickenThoughtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box("settings");

    return StreamBuilder(
      stream: box.watch(),
      builder: (context, asyncSnapshot) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;
            bool hasDynamicColor = lightDynamic != null && darkDynamic != null;
        
            // Use color schemes based on the user's wallpaper
            if (hasDynamicColor && box.get("color", defaultValue: hasDynamicColor? 0 : 3) == 0) {
              lightColorScheme = lightDynamic.harmonized();
              darkColorScheme = darkDynamic.harmonized();
            } else {
              // Otherwise, use fallback
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: colors[box.get("color", defaultValue: hasDynamicColor? 0 : 3)].color
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: colors[box.get("color", defaultValue: hasDynamicColor? 0 : 3)].color,
                brightness: Brightness.dark,
              );
            }

            SwitchThemeData switchTheme = SwitchThemeData(
              thumbIcon: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.check);
                }
                return const Icon(Icons.close);
              })
            );
        
            return MaterialApp(
              title: "Chicken Thoughts",
              themeMode: ThemeMode.values[box.get("theme", defaultValue: 0)],
              theme: ThemeData(
                colorScheme: lightColorScheme,
                switchTheme: switchTheme
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                switchTheme: switchTheme
              ),
              routes: {
                "/": (context) => HomePage(hasDynamicColor: hasDynamicColor),
                "/offline": (context) => OfflinePage(),
                "/settings": (context) => SettingsPage(hasDynamicColor: hasDynamicColor),
                "/settings/color": (context) => SettingsColorPage(
                  hasDynamicColor: hasDynamicColor,
                  dynamicColorScheme: Theme.of(context).brightness == Brightness.light? lightDynamic?.harmonized() : darkDynamic?.harmonized()
                ),
                "/settings/notifications": (context) => SettingsNotificationPage(),
                if (!kIsWeb) "/settings/caching": (context) => SettingsCachingPage()
              },
            );
          }
        );
      }
    );
  }
}