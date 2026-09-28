import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CleanDBHelper {
  // Clear data
  Future<void> checkAppVersionAndClearData({bool forceClear = false}) async {
    // Initialize SharedPreferences and PackageInfo
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Get the current version of the app
    String currentVersion = packageInfo.version;

    // Get the saved version from SharedPreferences
    String? savedVersion = prefs.getString('app_version');

    // Clear temporary/cache directory
    await _clearTemporaryDirectory();

    // Check if the version has changed or forceClear is true
    if (forceClear || savedVersion == null || savedVersion != currentVersion) {
      // Clear SharedPreferences data
      await prefs.clear(); // Clear all stored preferences

      // Delete all databases by name
      // await deleteAllDatabases();

      // Save the current version to SharedPreferences after clearing data
      await prefs.setString('app_version', currentVersion);
    } else {}
  }

// Function to delete all SQLite databases
  Future<void> deleteAllDatabases() async {
    var databasesPath = await getDatabasesPath();
    var documentsPath =
        (await getApplicationDocumentsDirectory()).path; // Add this line

    // List of database names
    List<String> databaseNames = [
      'addJob.db',
      'dbGoodsData.db',
      'addTempJob.db',
      'dbTempGoodsData.db',
    ];

    for (String dbName in databaseNames) {
      String dbPath1 = '$databasesPath/$dbName'; // From getDatabasesPath()
      String dbPath2 =
          '$documentsPath/$dbName'; // From getApplicationDocumentsDirectory()

      bool dbExists1 = await File(dbPath1).exists();
      bool dbExists2 = await File(dbPath2).exists();

      if (dbExists1) {
        await File(dbPath1).delete();
      } else if (dbExists2) {
        await File(dbPath2).delete();
      } else {}
    }
  }

// Function to clear cache/temporary directory
  Future<void> _clearTemporaryDirectory() async {
    try {
      // Get the temporary directory (cache)
      Directory tempDir = await getTemporaryDirectory();

      if (tempDir.existsSync()) {
        // Delete the temporary directory and its contents
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      return;
    }
  }
}
