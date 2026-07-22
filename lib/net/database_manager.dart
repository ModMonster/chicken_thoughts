import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chicken_thoughts_notifications/data/app_data.dart';
import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/data/streak_manager.dart';
import 'package:chicken_thoughts_notifications/data/user.dart';
import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class DatabaseManager {
  static const String endpoint = "https://tor.cloud.appwrite.io/v1";
  static const String projectId = "698f46a0001a9a273833";
  static const String databaseId = "698f575a000e90a717d2";
  static const String bucketId = "698f46d9000db58b334a";

  static late final Client client;
  static late final Storage storage;
  static late final TablesDB database;

  static void init() {
    client = Client()
      .setEndpoint(endpoint)
      .setProject(projectId);
    storage = Storage(client);
    database = TablesDB(client);
  }

  static Future<Holiday?> getHolidayOnDate(DateTime dateIn) async {
    final DateTime date = dateIn.copyWith(year: 2026, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    // Fetch list of holidays
    RowList holidays = await database.listRows(
      databaseId: databaseId,
      tableId: "holidays",
      queries: [
        Query.or([
          Query.equal("date", date.toIso8601String()), // The holiday is today
          Query.isNotNull("weekday") // The weird ones (tm)
        ])
      ]
    );

    // Loop through all retrieved holidays that could possibly be today
    for (Row row in holidays.rows) {
      DateTime holidayDate = DateTime.parse(row.data["date"]).copyWith(isUtc: false);

      // Holiday is exactly today
      if (row.data["weekday"] == null) {
        if (holidayDate.isAtSameMomentAs(date)) {
          return Holiday(
            name: row.data["name"],
            displayName: row.data["displayName"]
          );
        }
        continue;
      }

      // Holiday is based on day of week; check if we are in the correct month
      int month = holidayDate.month;
      if (month != date.month) continue;

      // Check if weekday matches
      Weekday weekday = Weekday.values.byName(row.data["weekday"].toString().toLowerCase());
      if (date.weekday - 1 != weekday.index) continue;

      // Check if weekday number matches
      int weekdayNumber = row.data["weekdayNumber"];
      int firstPossibleDay = 1 + 7 * (weekdayNumber - 1);
      int lastPossibleDay = 7 * weekdayNumber;
      
      if (date.day >= firstPossibleDay && date.day <= lastPossibleDay) {
        return Holiday(
          name: row.data["name"],
          displayName: row.data["displayName"]
        );
      }
    }
    
    // No holiday today!
    return null;
  }

  static Future<List<Season>> getSeasonList() async {
    // Fetch list of seasons
    RowList seasonRows = await database.listRows(
      databaseId: databaseId,
      tableId: "seasons"
    );

    // Build list
    List<Season> seasons = [];
    for (Row row in seasonRows.rows) {
      // Handle the normal season
      if (row.data["name"] == null) {
        seasons.add(Season(
          imageCount: row.data["imageCount"],
        ));
        continue;
      }

      DateTime startDate = DateTime.parse(row.data["startDate"]).subtract(Duration(seconds: 1))..copyWith(isUtc: false);
      DateTime endDate = DateTime.parse(row.data["endDate"]).add(Duration(seconds: 1))..copyWith(isUtc: false);

      seasons.add(Season(
        imageCount: row.data["imageCount"],
        imagePrefix: row.data["name"],
        displayName: row.data["displayName"],
        startDate: startDate,
        endDate: endDate
      ));
    }

    return seasons;
  }

  static Future<List<Holiday>> getHolidayList() async {
    // Fetch list of holidays
    RowList holidayRows = await database.listRows(
      databaseId: databaseId,
      tableId: "holidays"
    );

    // Build list
    List<Holiday> holidays = [];
    for (Row row in holidayRows.rows) {
      DateTime? date;
      if (row.data["date"] != null) {
        date = DateTime.parse(row.data["date"]).subtract(Duration(seconds: 1))..copyWith(isUtc: false);
      }

      holidays.add(Holiday(
        name: row.data["name"],
        displayName: row.data["displayName"],
        date: date,
        weekday: row.data["weekday"] == null? null : Weekday.values.byName(row.data["weekday"].toString().toLowerCase()),
        weekdayNumber: row.data["weekdayNumber"]
      ));
    }

    return holidays;
  }

  static Future<Season> getSeasonOnDate(DateTime dateIn) async {
    final DateTime date = dateIn.copyWith(year: 2026, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

    // Fetch list of seasons
    RowList seasons = await database.listRows(
      databaseId: databaseId,
      tableId: "seasons"
    );

    // Loop through all retrieved seasons
    Season? normalSeason;
    for (Row row in seasons.rows) {
      // Handle the normal season
      if (row.data["name"] == null) {
        normalSeason = Season(
          imageCount: row.data["imageCount"],
        );
      }

      DateTime startDate = DateTime.parse(row.data["startDate"]).subtract(Duration(seconds: 1))..copyWith(isUtc: false);
      DateTime endDate = DateTime.parse(row.data["endDate"]).add(Duration(seconds: 1))..copyWith(isUtc: false);

      if (startDate.isBefore(date) && endDate.isAfter(date)) {
        // 1/2 chance to just get the normal season
        if (randomBasedOnDateSeed(date, 2, extraSeed: 14) == 0) continue;

        return Season(
          imageCount: row.data["imageCount"],
          imagePrefix: row.data["name"],
          displayName: row.data["displayName"],
          startDate: startDate,
          endDate: endDate
        );
      }
    }
    
    return normalSeason!;
  }

  static Future<Season> getDefaultSeason() async {
    // Fetch list of seasons
    RowList seasons = await database.listRows(
      databaseId: databaseId,
      tableId: "seasons",
      queries: [
        Query.isNull("name")
      ]
    );

    return Season(
      imageCount: seasons.rows.first.data["imageCount"],
    );
  }

  static Future<ChickenThought> getChickenThoughtOnDate(DateTime date) async {
    Holiday? holiday = await getHolidayOnDate(date);
    if (holiday != null) {
      // Get holiday image
      String holidayPath = "holiday.${holiday.name}";
      Uint8List image = await getImageFromPath(holidayPath);

      return ChickenThought(
        holidayPath,
        displayName: holiday.displayName,
        image: image
      );
    }

    // Choose a random chicken thought based on the season
    Season season = await getSeasonOnDate(date);
    int imageNumber = randomBasedOnDateSeed(date, season.imageCount) + 1;
    String filePath = season.imagePrefix == null? imageNumber.toString() : "season.${season.imagePrefix}.$imageNumber";
    Uint8List image = await getImageFromPath(filePath);

    String displayName = "${season.displayName != null ? "Chicken Thoughts: ${season.displayName}" : "Chicken Thought"} #$imageNumber";
    return ChickenThought(filePath, displayName: displayName, image: image);
  }

  static Future<ChickenThought> getDailyChickenThought() async {
    StreakManager.handleStreak();
    return getChickenThoughtOnDate(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
  }

  static Future<Uint8List> getImageFromPath(String path) async {   
    // Hit cache if it exists
    Uint8List? cacheHit = await CacheManager.getImageFromPath(path);
    if (cacheHit != null) return cacheHit;

    FileList files = await storage.listFiles(
      bucketId: bucketId,
      queries: [
        Query.equal("name", "$path.jpg")
      ]
    );

    List<String> ids = files.files.map((e) => e.$id).toList();

    Uint8List image = await storage.getFileView(
      bucketId: bucketId,
      fileId: ids.first
    );

    // add image to cache
    CacheManager.addToCache(path, image);

    return image;
  }

  static int randomBasedOnDateSeed(DateTime date, int maxValueExclusive, {int extraSeed = 0}) {
    return Random(((date.millisecondsSinceEpoch - 18000000) / 86400000).floor() + extraSeed).nextInt(maxValueExclusive);
  }

  static DateTime getTodayWithoutYear() {
    return DateTime.now().copyWith(year: 2026, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  static Future<Uint8List> getThumbnailFromPath(String path) async {
    return await getImageFromPath("thumb.$path");
  }

  static Future<AppData> getRemoteAppData() async {
    AppData appData;
    try {
      Row appInfo = (await database.listRows(
        databaseId: databaseId,
        tableId: "app"
      )).rows.first;
      appData = AppData(
        latestVersion: appInfo.data["latestVersion"],
        minVersion: appInfo.data["minVersion"]
      );
    } catch (e) {
      if (kDebugMode) print("Error fetching remote app data: $e\nSetting app to offline mode");
      appData = AppData.offline();
    }

    return appData;
  }

  static Future<int> getRemoteCacheVersion() async {
    Row appInfo = (await database.listRows(
      databaseId: databaseId,
      tableId: "app"
    )).rows.first;

    return appInfo.data["cacheVersion"];
  }

  static Future<List<ChickenThoughtsUser>> getUsersMatchingName(String q) async {
    RowList userRows = await database.listRows(
      databaseId: databaseId,
      tableId: "users",
      queries: [
        Query.contains("name", q)
      ]
    );

    List<ChickenThoughtsUser> users = [];
    for (Row row in userRows.rows) {
      users.add(ChickenThoughtsUser(
        id: row.$id,
        name: row.data["name"],
        iconFg: row.data["iconFg"],
        iconBg: row.data["iconBg"]
      ));
    }

    return users;
  }

  static Future<void> createUser(String id, String name, int iconFg, int iconBg) async {
    await database.createRow(
      databaseId: databaseId,
      tableId: "users",
      rowId: id,
      data: {
        "name": name,
        "iconFg": iconFg,
        "iconBg": iconBg
      }
    );
  }

  static Future<void> updateUser(String id, String name, int iconFg, int iconBg) async {
    await database.updateRow(
      databaseId: databaseId,
      tableId: "users",
      rowId: id,
      data: {
        "name": name,
        "iconFg": iconFg,
        "iconBg": iconBg
      }
    );
  }

  static Future<void> addReaction(String chickenThought, String emoji, double x, double y) async {
    await database.createRow(
      databaseId: databaseId,
      tableId: "reactions",
      rowId: ID.unique(),
      data: {
        "chickenThought": chickenThought,
        "user": Hive.box("settings").get("user.id"),
        "x": x,
        "y": y,
        "reaction": emoji
      }
    );
  }
}

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}