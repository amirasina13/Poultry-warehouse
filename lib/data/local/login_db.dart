import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/model.dart';

// Login List database
class DBMasterLoginList {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  /// Clears any legacy passwords or tokens accidentally stored in older versions of SQLite
  Future<void> sanitizeLegacyCredentials(Database db) async {
    try {
      await db.execute(
          "UPDATE loginList SET login_password = '', login_token = ''");
    } catch (e) {
      // Table might not exist yet during initial setup, safe to catch and ignore
    }
  }

  // Create new item
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'loginList.db');

    Future<void> dBColumnUpdate(Database db) async {
      final byproductColumns =
          await db.rawQuery("PRAGMA table_info(loginList)");
      final byproductColumnName =
          byproductColumns.map((col) => col['name'] as String).toSet();

      // Find the column specifically
      final loginIdCol = byproductColumns.firstWhere(
        (col) => col['name'] == 'login_id',
        orElse: () => {},
      );
      final locIdCol = byproductColumns.firstWhere(
        (col) => col['name'] == 'location_id',
        orElse: () => {},
      );
      final trayWeightCol = byproductColumns.firstWhere(
        (col) => col['name'] == 'tray_weight',
        orElse: () => {},
      );

      // 2. Check if the type is 'TEXT' (it needs to be 'REAL')
      if ((loginIdCol.isNotEmpty && loginIdCol['type'] == 'TEXT') &&
          (trayWeightCol.isNotEmpty && trayWeightCol['type'] == 'TEXT') &&
          (locIdCol.isNotEmpty && locIdCol['type'] == 'TEXT')) {
        await db.transaction((txn) async {
          // Step A: Rename
          await txn.execute("ALTER TABLE loginList RENAME TO loginList_old");

          // Step B: Create New with REAL type
          await txn.execute('''
        CREATE TABLE loginList(
          login_id INTEGER,
          login_username TEXT,
          login_password TEXT,
          login_email TEXT,
          login_token TEXT,
          location_id INTEGER,
          location_name TEXT,
          tray_weight REAL,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

          String createdAtSource =
              byproductColumnName.contains('created_at') ? 'created_at' : "''";
          String updatedAtSource =
              byproductColumnName.contains('updated_at') ? 'updated_at' : "''";

          // Step C: Copy and Convert
          await txn.execute('''
        INSERT INTO loginList (
          login_id, login_username, login_password, login_email, 
          login_token, location_id, location_name, tray_weight, 
          created_at, updated_at
        )
        SELECT 
          CAST(login_id AS INTEGER), login_username, login_password, login_email, 
          login_token, CAST(location_id AS INTEGER), location_name, CAST(tray_weight AS REAL), 
          $createdAtSource, $updatedAtSource 
        FROM loginList_old
      ''');

          //     await txn.execute('''
          //   INSERT INTO loginList SELECT
          //   CAST(login_id AS INTEGER), login_username, login_password, login_email,
          //   login_token, CAST(location_id AS INTEGER), location_name, CAST(tray_weight AS REAL),
          //   created_at, updated_at FROM loginList_old
          // ''');

          // Step D: Clean up
          await txn.execute("DROP TABLE loginList_old");
        });
      } else {
        if (!byproductColumnName.contains('created_at')) {
          await db.execute("ALTER TABLE loginList ADD COLUMN created_at TEXT");
        }
        if (!byproductColumnName.contains('updated_at')) {
          await db.execute("ALTER TABLE loginList ADD COLUMN updated_at TEXT");
        }
      }

      // final byproductColumnName =
      //     byproductColumns.map((col) => col['name'] as String).toSet();
    }

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        // Run migration check every time DB opens
        await dBColumnUpdate(db);

        // Sanitize and erase legacy passwords/tokens from SQLite on open
        await sanitizeLegacyCredentials(db);
      },
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE loginList('
            'login_id INTEGER,'
            'login_username TEXT,'
            'login_password TEXT,'
            'login_email TEXT,'
            'login_token TEXT,'
            'location_id INTEGER,'
            'location_name TEXT,'
            'tray_weight REAL,'
            'created_at TEXT,'
            'updated_at TEXT'
            ')');
      },
    );
  }

  // Insert login list into database
  Future<void> createMenuItem(LoginModel newLoginModel) async {
    final db = await database;
    Batch batch = db.batch();

    batch.insert('loginList', newLoginModel.toJson());
    batch.commit();
  }

  // Get all login list
  Future<dynamic> getAllLoginList() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM loginList");

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Delete all login list
  Future<int> deleteAllLoginList() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM loginList');

    return res;
  }

  // Update location login
  Future<dynamic> updateLoginData(
      {required int loginId,
      required int locationId,
      required String locationName,
      required double trayWeight,
      required String updatedAt}) async {
    final db = await database;

    var results = await db.rawQuery(
        'UPDATE loginList SET location_id = ?, location_name = ?, tray_weight = ?, updated_at = ? WHERE login_id = ?',
        [locationId, locationName, trayWeight, updatedAt, loginId]);
    return results;
  }
}
