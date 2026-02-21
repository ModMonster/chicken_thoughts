import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chicken_thoughts_notifications/data/app_data.dart';
import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/data/season.dart';
import 'package:chicken_thoughts_notifications/net/cache_manager.dart';
import 'package:flutter/foundation.dart';

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

  static Future<Holiday?> getHolidayToday() async {
    final today = getToday();

    // Fetch list of holidays
    RowList holidays = await database.listRows(
      databaseId: databaseId,
      tableId: "holidays",
      queries: [
        Query.or([
          Query.equal("date", today.copyWith(year: 2026).toIso8601String()), // The holiday is today
          Query.isNotNull("weekday") // The weird ones (tm)
        ])
      ]
    );

    // Loop through all retrieved holidays that could possibly be today
    for (Row row in holidays.rows) {
      DateTime holidayDate = DateTime.parse(row.data["date"]).copyWith(isUtc: false);

      // Holiday is exactly today
      if (holidayDate.isAtSameMomentAs(today.copyWith(year: 2026))) {
        return Holiday(
          name: row.data["name"],
          displayName: row.data["displayName"]
        );
      }

      // Check for something that got through without a weekday
      if (row.data["weekday"] == null) continue;

      // Holiday is based on day of week; check if we are in the correct month
      int month = holidayDate.month;
      if (month != today.month) continue;

      // Check if weekday matches
      Weekday weekday = Weekday.values.byName(row.data["weekday"].toString().toLowerCase());
      if (today.weekday - 1 != weekday.index) continue;

      // Check if weekday number matches
      int weekdayNumber = row.data["weekdayNumber"];
      int firstPossibleDay = 1 + 7 * (weekdayNumber - 1);
      int lastPossibleDay = 7 * weekdayNumber;
      
      if (today.day >= firstPossibleDay && today.day <= lastPossibleDay) {
        return Holiday(
          name: row.data["name"],
          displayName: row.data["displayName"]
        );
      }
    }
    
    // No holiday today!
    return null;
  }

  static Future<Season> getSeasonToday() async {
    final today = getToday();

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

      if (startDate.isBefore(today) && endDate.isAfter(today)) {
        // 1/2 chance to just get the normal season
        if (randomBasedOnDateSeed(2, extraSeed: 14) == 0) continue;

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

  static Future<ChickenThought> getDailyChickenThought() async {
    Holiday? holiday = await getHolidayToday();
    if (holiday != null) {
      // Get all images corresponding to this holiday
      String holidayPath = "holiday.${holiday.name}";
      List<Uint8List> images = await getImagesFromPath(holidayPath);
      // TODO: this will unnessicarily download all images for a holiday even though we only need one

      // Choose a random one based on today's date as a seed
      int index = randomBasedOnDateSeed(images.length);
      return ChickenThought(
        images.length > 1 ? "$holidayPath.$index" : holidayPath,
        displayName: holiday.displayName,
        images: images
      );
    }

    // Choose a random chicken thought based on the season
    Season season = await getSeasonToday();
    int imageNumber = randomBasedOnDateSeed(season.imageCount) + 1;
    String filePath = season.imagePrefix == null? imageNumber.toString() : "season.${season.imagePrefix}.$imageNumber";
    List<Uint8List> images = await getImagesFromPath(filePath);

    String displayName = "${season.displayName != null ? "Chicken Thoughts: ${season.displayName}" : "Chicken Thought"} #$imageNumber";
    return ChickenThought(filePath, displayName: displayName, images: images);
  }

  // Get all images corresponding to a filename
  // e.g. holiday.fathers_day will give holiday.fathers_day.1.jpg and holiday.fathers_day.2.jpg
  static Future<List<Uint8List>> getImagesFromPath(String path) async {   
    // Hit cache if it exists
    List<Uint8List>? cacheHitResults = await CacheManager.getImagesFromPath(path);
    if (cacheHitResults != null && cacheHitResults.isNotEmpty) return cacheHitResults;

    FileList files = await storage.listFiles(
      bucketId: bucketId,
      queries: [
        Query.or([
          Query.equal("name", "$path.jpg"),
          Query.startsWith("name", "$path.")
        ])
      ]
    );

    List<String> ids = files.files.map((e) => e.$id).toList();
    List<Uint8List> images = [];

    for (String id in ids) {
      images.add(await storage.getFileView(
        bucketId: bucketId,
        fileId: id
      ));
    }

    // Add images to cache
    if (images.length > 1) {
      for (int i = 0; i < images.length; i++) {
        CacheManager.addToCache("$path.${i+1}", images[i]);
      }
    } else {
      CacheManager.addToCache(path, images[0]);
    }

    return images;
  }

  static Future<Uint8List> getImageFromExactPath(String path) async {   
    // Hit cache if it exists
    List<Uint8List>? cacheHitResults = await CacheManager.getImagesFromPath(path);
    if (cacheHitResults != null && cacheHitResults.isNotEmpty) return cacheHitResults.first;

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

  static int randomBasedOnDateSeed(int maxValueExclusive, {int extraSeed = 0}) {
    return Random(((DateTime.now().millisecondsSinceEpoch - 18000000) / 86400000).floor() + extraSeed).nextInt(maxValueExclusive);
  }

  static DateTime getToday() {
    return DateTime.now().copyWith(year: 2026, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  static Future<Uint8List> getImagePreviewFromPath(String path) async {
    List<Uint8List> thumbs = await getImagesFromPath("thumb.$path");
    if (thumbs.isEmpty) {
      throw Exception("No image IDs found for path: $path");
    }
    return thumbs.first;
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

  static Future<Uint8List> downloadFile(String fileId) async {
    if (kDebugMode) print("Downloading file: $fileId");
    return await storage.getFileDownload(
      bucketId: bucketId,
      fileId: fileId
    );
  }

  static Future<FileList> getCacheFiles() async {
    return await storage.listFiles(
      bucketId: bucketId,
      queries: [
        Query.startsWith("name", "caches")
      ]
    );
  }

  static Future<int> getRemoteCacheSize() async {
    Row appInfo = (await database.listRows(
      databaseId: databaseId,
      tableId: "app"
    )).rows.first;

    return appInfo.data["cacheSize"];
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