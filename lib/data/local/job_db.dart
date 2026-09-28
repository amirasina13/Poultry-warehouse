import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../model/model.dart';

// db for add job
class DBJobData {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> dBColumnUpdate(Database db) async {
    final byproductColumns = await db.rawQuery("PRAGMA table_info(AddJob)");
    final byproductColumnName =
        byproductColumns.map((col) => col['name'] as String).toSet();

    // Find the column specifically
    final pllIdCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'pll_id',
      orElse: () => {},
    );
    final plCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'pl_id',
      orElse: () => {},
    );
    final sdIdCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'sd_id',
      orElse: () => {},
    );
    final ttIdCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'tt_id',
      orElse: () => {},
    );
    final flIdCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'fl_id',
      orElse: () => {},
    );
    final toLocCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'tl_id',
      orElse: () => {},
    );
    final faIdCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'fa_id',
      orElse: () => {},
    );
    final taCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'ta_id',
      orElse: () => {},
    );
    final ibyCol = byproductColumns.firstWhere(
      (col) => col['name'] == 'iby_id',
      orElse: () => {},
    );

    // Check if the type is 'TEXT' (it needs to be 'REAL')
    if ((pllIdCol.isNotEmpty && pllIdCol['type'] == 'TEXT') &&
        (plCol.isNotEmpty && plCol['type'] == 'TEXT') &&
        (sdIdCol.isNotEmpty && sdIdCol['type'] == 'TEXT') &&
        (ttIdCol.isNotEmpty && ttIdCol['type'] == 'TEXT') &&
        (flIdCol.isNotEmpty && flIdCol['type'] == 'TEXT') &&
        (toLocCol.isNotEmpty && toLocCol['type'] == 'TEXT') &&
        (faIdCol.isNotEmpty && faIdCol['type'] == 'TEXT') &&
        (taCol.isNotEmpty && taCol['type'] == 'TEXT') &&
        (ibyCol.isNotEmpty && ibyCol['type'] == 'TEXT')) {
      await db.transaction((txn) async {
        // Step A: Rename
        await txn.execute("ALTER TABLE AddJob RENAME TO AddJob_old");

        // Step B: Create New with REAL type
        await txn.execute('''
        CREATE TABLE AddJob(
            j_id INTEGER PRIMARY KEY AUTOINCREMENT,
            j_status TEXT, 
            pll_id INTEGER,  
            pl_location TEXT,  
            tr_id TEXT,  
            t TEXT,  
            d_time TEXT,  
            pl_id INTEGER,  
            pl_no TEXT,  
            sd_id INTEGER,  
            s_document TEXT,  
            d_no TEXT,  
            tt_id INTEGER,  
            t_type TEXT,  
            fl_id INTEGER,  
            fl_name TEXT,  
            tl_id INTEGER, 
            tl_name TEXT,                                            
            fa_id INTEGER, 
            fa_name TEXT, 
            ta_id INTEGER,  
            ta_name TEXT,
            reasonId INTEGER,
            reasonName TEXT,
            remark TEXT,  
            iby_id INTEGER,  
            i_by TEXT,  
            created_at TEXT,
            updated_at TEXT
        )
      ''');

        String col(String name, {String fallback = "NULL"}) {
          return byproductColumnName.contains(name) ? name : fallback;
        }

        await txn.execute('''
        INSERT INTO AddJob (
          j_id, j_status, pll_id, pl_location, tr_id, t, d_time, pl_id, pl_no, 
          sd_id, s_document, d_no, tt_id, t_type, fl_id, fl_name, tl_id, tl_name, 
          fa_id, fa_name, ta_id, ta_name, reasonId, reasonName, remark, iby_id, 
          i_by, created_at, updated_at
        ) 
        SELECT 
          j_id, j_status, 
          CAST(${col('pll_id')} AS INTEGER), pl_location, tr_id, t, d_time, 
          CAST(${col('pl_id')} AS INTEGER), pl_no, 
          CAST(${col('sd_id')} AS INTEGER), s_document, d_no, 
          CAST(${col('tt_id')} AS INTEGER), t_type, 
          CAST(${col('fl_id')} AS INTEGER), fl_name, 
          CAST(${col('tl_id')} AS INTEGER), tl_name, 
          CAST(${col('fa_id')} AS INTEGER), fa_name, 
          CAST(${col('ta_id')} AS INTEGER), ta_name, 
          ${col('reasonId', fallback: '0')}, 
          ${col('reasonName', fallback: "''")}, 
          remark, 
          CAST(${col('iby_id')} AS INTEGER), i_by, 
          ${col('created_at', fallback: "''")}, 
          ${col('updated_at', fallback: "''")}
        FROM AddJob_old
      ''');

        // Step C: Copy and Convert
        //   await txn.execute('''
        //   INSERT INTO AddJob SELECT
        //       j_id,
        //       j_status,
        //       CAST(pll_id AS INTEGER),
        //       pl_location,
        //       tr_id,
        //       t,
        //       d_time,
        //       CAST(pl_id AS INTEGER),
        //       pl_no,
        //       CAST(sd_id AS INTEGER),
        //       s_document,
        //       d_no,
        //       CAST(tt_id AS INTEGER),
        //       t_type,
        //       CAST(fl_id AS INTEGER),
        //       fl_name,
        //       CAST(tl_id AS INTEGER),
        //       tl_name,
        //       CAST(fa_id AS INTEGER),
        //       fa_name,
        //       CAST(ta_id AS INTEGER),
        //       ta_name,
        //       reasonId,
        //       reasonName,
        //       remark,
        //       CAST(iby_id AS INTEGER),
        //       i_by,
        //       created_at,
        //       updated_at FROM AddJob_old
        // ''');

        // Step D: Clean up
        await txn.execute("DROP TABLE AddJob_old");
      });
    } else {
      // If table rebuild wasn't needed, check for missing columns individually
      final columnsToAdd = {
        'created_at': 'TEXT',
        'updated_at': 'TEXT',
        'reasonId': 'INTEGER',
        'reasonName': 'TEXT',
      };

      for (var entry in columnsToAdd.entries) {
        if (!byproductColumnName.contains(entry.key)) {
          await db.execute(
              "ALTER TABLE AddJob ADD COLUMN ${entry.key} ${entry.value}");
        }
      }
    }

    // final byproductColumnName =
    //     byproductColumns.map((col) => col['name'] as String).toSet();

    // if (!byproductColumnName.contains('created_at')) {
    //   // PrintLog()
    //   //     .log("Migrating schema: Adding 'created_at' to AddJob");
    //   await db.execute("ALTER TABLE AddJob ADD COLUMN created_at TEXT");
    // }
    // if (!byproductColumnName.contains('updated_at')) {
    //   // PrintLog()
    //   //     .log("Migrating schema: Adding 'updated_at' to AddJob");
    //   await db.execute("ALTER TABLE AddJob ADD COLUMN updated_at TEXT");
    // }

    // if (!byproductColumnName.contains('reasonId')) {
    //   // PrintLog()
    //   //     .log("Migrating schema: Adding 'updated_at' to AddJob");
    //   await db.execute("ALTER TABLE AddJob ADD COLUMN reasonId INTEGER");
    // }
    // if (!byproductColumnName.contains('reasonName')) {
    //   // PrintLog()
    //   //     .log("Migrating schema: Adding 'updated_at' to AddJob");
    //   await db.execute("ALTER TABLE AddJob ADD COLUMN reasonName TEXT");
    // }
  }

  // Create the database for add job
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'addJob.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        // Run migration check every time DB opens
        await dBColumnUpdate(db);
      },
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute('CREATE TABLE AddJob('
            'j_id INTEGER PRIMARY KEY AUTOINCREMENT,' // job id
            'j_status TEXT,' // Job Status ONGOING/ COMPLETE..
            'pll_id INTEGER,' // Location id
            'pl_location TEXT,' // Location name
            'tr_id TEXT,' // Transaction NO
            't TEXT,' // Type OUT/IN
            'd_time TEXT,' // Date Time
            'pl_id INTEGER,' // Picking List ID
            'pl_no TEXT,' // Picking List No
            'sd_id INTEGER,' // Select Document ID
            's_document TEXT,' // Select Document
            'd_no TEXT,' // Document No
            'tt_id INTEGER,' // Type of Transfer ID
            't_type TEXT,' // Type of Transfer
            'fl_id INTEGER,' // From Location ID
            'fl_name TEXT,' // From Location Name
            'tl_id INTEGER,' // To Location ID
            'tl_name TEXT,' // To Location Name                                               // To Location Name
            'fa_id INTEGER,' // From Area ID
            'fa_name TEXT,' // From Area Name
            'ta_id INTEGER,' // To Area ID
            'ta_name TEXT,'
            'reasonId INTEGER,'
            'reasonName TEXT,'
            'remark TEXT,' // Remark
            'iby_id INTEGER,' // Issued By ID
            'i_by TEXT,' // Issued By
            'created_at TEXT,'
            'updated_at TEXT'
            ')');
      },
      onConfigure: _onConfigure,
    );
  }

  // Insert data into Add Job
  Future<dynamic> createAddJob(JobModel newAddJob) async {
    // Get a reference to the database
    final db = await database;
    final result = await db.insert(
      'AddJob',
      newAddJob.toJson(),
    );

    if (result > 0) {
      return true;
    }

    return false;
  }

  // Get all Job
  Future<dynamic> getAllAddJob() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM addJob");

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all Job by ID
  Future<dynamic> getAddJobFromJOID(int jobID) async {
    final db = await database;
    final res =
        await db.rawQuery("SELECT * FROM addJob WHERE j_id = ?", [jobID]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all job by Tr ID
  Future<dynamic> getAddJobFromTrID(String transactionID) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM addJob WHERE tr_id = ?", [transactionID]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all job based type and job id
  Future<dynamic> getAddJobFromType(String type, int jobID) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM addJob WHERE t = ? AND j_id = ?", [type, jobID]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all job based status and type
  Future<dynamic> getAddJobFromStatus(String type, String jobStatus) async {
    final db = await database;
    final res = await db.rawQuery(
        "SELECT * FROM addJob WHERE t = ? AND j_status = ?", [type, jobStatus]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all job based status and type
  Future<dynamic> getAddJobFromStatusOnly(String jobStatus) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM addJob WHERE j_status = ?", [jobStatus]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Delete all Job
  Future<int> deleteAllAddJob() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM addJob');

    return res;
  }

  // Delete one Job
  Future<int> deleteIDAddJob(int jobID) async {
    final db = await database;
    final res =
        await db.rawDelete('DELETE FROM addJob WHERE j_id = ?', [jobID]);

    return res;
  }

  Future<void> deleteBulksAddJob(List<dynamic> jobIDs) async {
    if (jobIDs.isEmpty) return;

    final db = await database;

    final placeholders = List.filled(jobIDs.length, '?').join(',');

    await db.delete(
      'addJob',
      where: 'j_id IN ($placeholders)',
      whereArgs: jobIDs,
    );
  }

  // Update selected Job base on ID
  Future<dynamic> updateJob(JobModel jobModel, int jobId) async {
    final db = await database;
    Map<String, dynamic> row = {
      'j_status': jobModel.jobStatus,
      'pll_id': jobModel.pickingListLocationId,
      'pl_location': jobModel.pickingListLocation,
      'tr_id': jobModel.transactionID,
      't': jobModel.type,
      'd_time': jobModel.dateTime,
      'pl_id': jobModel.pickingListID,
      'pl_no': jobModel.pickingListNo,
      'sd_id': jobModel.selectDocumentID,
      's_document': jobModel.selectDocument,
      'd_no': jobModel.documentNo,
      'tt_id': jobModel.typeOfTransferId,
      't_type': jobModel.typeOfTransfer,
      'fl_id': jobModel.fromLocationID,
      'fl_name': jobModel.fromLocationName,
      'tl_id': jobModel.toLocationID,
      'tl_name': jobModel.toLocationName,
      'fa_id': jobModel.fromAreaID,
      'fa_name': jobModel.fromAreaName,
      'ta_id': jobModel.toAreaID,
      'ta_name': jobModel.toAreaName,
      'reasonId': jobModel.reasonId,
      'reasonName': jobModel.reasonName,
      'remark': jobModel.remark,
      'iby_id': jobModel.issuedByID,
      'i_by': jobModel.issuedBy,
      'created_at': jobModel.createdAt,
      'updated_at': jobModel.updatedAt,
    };

    return await db.update(
      'addJob', // e.g., 'add_job_table'
      row,
      where: 'j_id = ?',
      whereArgs: [jobId],
    );
  }

  // Update individually
  Future<dynamic> updateJobIndividually(
      int jobID, String fieldName, dynamic newValue) async {
    final db = await database;
    var results = await db.rawQuery(
        'UPDATE addJob SET $fieldName = ? WHERE j_id = ?', [newValue, jobID]);
    return results;
  }
}
