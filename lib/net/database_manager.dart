import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chicken_thoughts_notifications/data/app_data.dart';
import 'package:chicken_thoughts_notifications/data/chicken_thought.dart';
import 'package:chicken_thoughts_notifications/data/holiday.dart';
import 'package:chicken_thoughts_notifications/data/season.dart';

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
      DateTime holidayDate = DateTime.parse(row.data["date"]);

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

      DateTime startDate = DateTime.parse(row.data["startDate"]).subtract(Duration(seconds: 1));
      DateTime endDate = DateTime.parse(row.data["endDate"]).add(Duration(seconds: 1));

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

  static Future<ChickenThought> getDailyChickenThought() async {
    Holiday? holiday = await getHolidayToday();
    if (holiday != null) {
      // Get all images corresponding to this holiday
      List<String> ids = await getImageIdsFromPath("holiday.${holiday.name}");

      // Choose a random one based on today's date as a seed
      int index = randomBasedOnDateSeed(ids.length);
      return ChickenThought(
        displayName: holiday.displayName,
        storageIds: [ids[index]]
      );
    }

    // Choose a random chicken thought based on the season
    Season season = await getSeasonToday();
    int imageNumber = randomBasedOnDateSeed(season.imageCount) + 1;
    String filePath = season.imagePrefix == null? imageNumber.toString() : "season.${season.imagePrefix}.$imageNumber";
    List<String> imageIds = await getImageIdsFromPath(filePath);

    String displayName = "${season.displayName != null ? "Chicken Thoughts: ${season.displayName}" : "Chicken Thought"} #$imageNumber";
    return ChickenThought(displayName: displayName, storageIds: imageIds);
  }

  // Get all image IDs corresponding to a filename
  // e.g. holiday.fathers_day will give holiday.fathers_day.1.jpg and holiday.fathers_day.2.jpg
  static Future<List<String>> getImageIdsFromPath(String path) async {
    FileList files = await storage.listFiles(
      bucketId: bucketId,
      queries: [
        Query.startsWith("name", path)
      ]
    );

    List<String> ids = files.files.map((e) => e.$id).toList();
    return ids;
  }

  // Get all image IDs corresponding to an exact filename
  // e.g. holiday.fathers_day.1 will give holiday.fathers_day.1.jpg
  static Future<String> getImageIdFromPath(String path) async {
    FileList files = await storage.listFiles(
      bucketId: bucketId,
      queries: [
        Query.equal("name", "$path.jpg")
      ]
    );
    return files.files.first.$id;
  }

  static int randomBasedOnDateSeed(int maxValueExclusive, {int extraSeed = 0}) {
    return Random(((DateTime.now().toUtc().millisecondsSinceEpoch - 18000000) / 86400000).floor() + extraSeed).nextInt(maxValueExclusive);
  }

  static DateTime getToday() {
    return DateTime.now().toUtc().copyWith(year: 2026, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  static Future<Uint8List> getImageFromId(String id) {
    return storage.getFileView(
      bucketId: bucketId,
      fileId: id
    );
  }

  static Future<List<Uint8List>> getImagesFromIds(List<String> ids) async {
    List<Uint8List> images = [];

    for (String id in ids) {
      images.add(await storage.getFileView(
        bucketId: bucketId,
        fileId: id
      ));
    }

    return images;
  }

  static Future<AppData> getRemoteAppData() async {
    Row appInfo = (await database.listRows(
      databaseId: databaseId,
      tableId: "app"
    )).rows.first;

    return AppData(
      latestVersion: appInfo.data["latestVersion"],
      minVersion: appInfo.data["minVersion"]
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