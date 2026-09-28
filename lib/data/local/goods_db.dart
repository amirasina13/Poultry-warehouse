import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../model/model.dart';

// db for goods data
class DBGoodsData {
  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> dbColumnUpdate(Database db) async {
    final goodsColumns = await db.rawQuery("PRAGMA table_info(GoodsData)");
    // final existingColumnNames =
    //     goodsColumns.map((col) => col['name'] as String).toSet();
    final goodsColumnName =
        goodsColumns.map((col) => col['name'] as String).toSet();

    // Find the column specifically
    final pldIdCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'pld_id',
      orElse: () => {},
    );
    final catCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'ct_id',
      orElse: () => {},
    );
    final gsCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'gs_id',
      orElse: () => {},
    );
    final tQtyCol = goodsColumns.firstWhere(
      (col) => col['name'] == 't_quantity',
      orElse: () => {},
    );
    final tMaxCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'tq_max',
      orElse: () => {},
    );
    final tqnMaxCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'tqn_max',
      orElse: () => {},
    );
    final tWeightCol = goodsColumns.firstWhere(
      (col) => col['name'] == 't_weight',
      orElse: () => {},
    );
    final twMaxCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'tw_max',
      orElse: () => {},
    );
    final twnMaxCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'twn_max',
      orElse: () => {},
    );
    final tTrayCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'tt_tray',
      orElse: () => {},
    );
    final sTrolleyCol = goodsColumns.firstWhere(
      (col) => col['name'] == 's_trolley',
      orElse: () => {},
    );
    final stWeightCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'st_weight',
      orElse: () => {},
    );
    final ntWeightCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'nt_weight',
      orElse: () => {},
    );
    final uqCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'uq_id',
      orElse: () => {},
    );
    final uwCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'uw_id',
      orElse: () => {},
    );
    final qtyControlCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'q_control',
      orElse: () => {},
    );
    final wControlCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'w_control',
      orElse: () => {},
    );
    final sbCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'sb_id',
      orElse: () => {},
    );
    final brandCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'b_id',
      orElse: () => {},
    );
    final clientCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'c_id',
      orElse: () => {},
    );
    final vendorCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'v_id',
      orElse: () => {},
    );
    final areaCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'a_id',
      orElse: () => {},
    );
    final rackCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'r_id',
      orElse: () => {},
    );
    final palletCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'p_id',
      orElse: () => {},
    );
    final statusCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'status',
      orElse: () => {},
    );
    final dbStatusCol = goodsColumns.firstWhere(
      (col) => col['name'] == 'dbStatus',
      orElse: () => {},
    );

    // 2. Check if the type is 'TEXT' (it needs to be 'REAL')
    if ((pldIdCol.isNotEmpty && pldIdCol['type'] == 'TEXT') ||
        (catCol.isNotEmpty && catCol['type'] == 'TEXT') ||
        (gsCol.isNotEmpty && gsCol['type'] == 'TEXT') ||
        (tQtyCol.isNotEmpty && tQtyCol['type'] == 'TEXT') ||
        (tMaxCol.isNotEmpty && tMaxCol['type'] == 'TEXT') ||
        (tqnMaxCol.isNotEmpty && tqnMaxCol['type'] == 'TEXT') ||
        (tWeightCol.isNotEmpty && tWeightCol['type'] == 'TEXT') ||
        (twMaxCol.isNotEmpty && twMaxCol['type'] == 'TEXT') ||
        (twnMaxCol.isNotEmpty && twnMaxCol['type'] == 'TEXT') ||
        (tTrayCol.isNotEmpty && tTrayCol['type'] == 'TEXT') ||
        (sTrolleyCol.isNotEmpty && sTrolleyCol['type'] == 'TEXT') ||
        (stWeightCol.isNotEmpty && stWeightCol['type'] == 'TEXT') ||
        (ntWeightCol.isNotEmpty && ntWeightCol['type'] == 'TEXT') ||
        (uqCol.isNotEmpty && uqCol['type'] == 'TEXT') ||
        (uwCol.isNotEmpty && uwCol['type'] == 'TEXT') ||
        (qtyControlCol.isNotEmpty && qtyControlCol['type'] == 'TEXT') ||
        (wControlCol.isNotEmpty && wControlCol['type'] == 'TEXT') ||
        (sbCol.isNotEmpty && sbCol['type'] == 'TEXT') ||
        (brandCol.isNotEmpty && brandCol['type'] == 'TEXT') ||
        (clientCol.isNotEmpty && clientCol['type'] == 'TEXT') ||
        (vendorCol.isNotEmpty && vendorCol['type'] == 'TEXT') ||
        (areaCol.isNotEmpty && areaCol['type'] == 'TEXT') ||
        (rackCol.isNotEmpty && rackCol['type'] == 'TEXT') ||
        (palletCol.isNotEmpty && palletCol['type'] == 'TEXT') ||
        (statusCol.isNotEmpty && statusCol['type'] == 'TEXT') ||
        (dbStatusCol.isNotEmpty && dbStatusCol['type'] == 'TEXT')) {
      await db.transaction((txn) async {
        // Step A: Rename
        await txn.execute("ALTER TABLE GoodsData RENAME TO GoodsData_old");

        // Step B: Create New with REAL type
        await txn.execute('''
        CREATE TABLE GoodsData(
            g_id INTEGER PRIMARY KEY AUTOINCREMENT, 
            list_index INTEGER,
            g_type TEXT, 
            ct_id INTEGER,  
            ct_name TEXT,  
            pld_id INTEGER,  
            j_stattq_maxus TEXT,
            gs_id INTEGER,  
            gs_name TEXT,  
            sku_name TEXT,  
            t_quantity INTEGER,  
            tq_max INTEGER,  
            tqn_max INTEGER,  
            t_weight REAL,  
            tw_max REAL,  
            twn_max REAL,  
            tt_tray INTEGER, 
            tray_weight REAL,
            s_trolley INTEGER,  
            st_weight REAL,  
            nt_weight REAL, 
            uq_id INTEGER, 
            uq_name TEXT,  
            uw_id INTEGER,  
            uw_name TEXT,  
            q_control INTEGER,  
            w_control INTEGER, 
            sb_id INTEGER, 
            pb_no TEXT,  
            p_date TEXT, 
            e_date TEXT,
            expire_days INTEGER,  
            b_id INTEGER,  
            b_name TEXT, 
            c_id INTEGER,  
            c_name TEXT,  
            v_id INTEGER,  
            v_name TEXT,  
            remarks TEXT, 
            a_id INTEGER, 
            a_name TEXT,  
            r_id INTEGER,  
            r_name TEXT,  
            p_id INTEGER,  
            p_name TEXT,  
            is_grouped INTEGER,  
            grouped_ids TEXT, 
            status INTEGER, 
            j_id INTEGER,  
            tr_id TEXT, 
            stockBalanceId INTEGER,  
            stockBalanceQty INTEGER,  
            stockBalanceWeight REAL,  
            created_at TEXT,
            updated_at TEXT,
            dbStatus INTEGER DEFAULT 'ACTIVE'
        )
      ''');

        String col(String name, {String fallback = "NULL"}) {
          return goodsColumnName.contains(name) ? name : fallback;
        }

        // Step C: Copy and Convert
        await txn.execute('''
        INSERT INTO GoodsData (
            g_id, list_index, g_type, ct_id, ct_name, pld_id, j_stattq_maxus, gs_id, gs_name, 
            sku_name, t_quantity, tq_max, tqn_max, t_weight, tw_max, twn_max, 
            tt_tray, tray_weight, s_trolley, st_weight, nt_weight, uq_id, uq_name, uw_id, 
            uw_name, q_control, w_control, sb_id, pb_no, p_date, e_date, expire_days, b_id, 
            b_name, c_id, c_name, v_id, v_name, remarks, a_id, a_name, r_id, 
            r_name, p_id, p_name, is_grouped, grouped_ids, status, j_id, tr_id, 
            stockBalanceId, stockBalanceQty, stockBalanceWeight, created_at, updated_at, dbStatus
        ) 
        SELECT 
            g_id, 
            list_index, g_type, 
            CAST(${col('ct_id')} AS INTEGER), ct_name, 
            CAST(${col('pld_id')} AS INTEGER), ${col('j_stattq_maxus')},
            CAST(${col('gs_id')} AS INTEGER), gs_name, 
            ${col('sku_name', fallback: "''")}, 
            CAST(${col('t_quantity')} AS INTEGER), CAST(${col('tq_max')} AS INTEGER), CAST(${col('tqn_max')} AS INTEGER), 
            CAST(${col('t_weight')} AS REAL), CAST(${col('tw_max')} AS REAL), CAST(${col('twn_max')} AS REAL), 
            CAST(${col('tt_tray')} AS INTEGER), ${col('tray_weight', fallback: '0.0')}, 
            CAST(${col('s_trolley')} AS INTEGER), CAST(${col('st_weight')} AS REAL), CAST(${col('nt_weight')} AS REAL), 
            CAST(${col('uq_id')} AS INTEGER), ${col('uq_name')}, 
            CAST(${col('uw_id')} AS INTEGER), ${col('uw_name')}, 
            CAST(${col('q_control')} AS INTEGER), CAST(${col('w_control')} AS INTEGER), 
            CAST(${col('sb_id')} AS INTEGER), pb_no, p_date, e_date, 
            ${col('expire_days', fallback: '0')},
            CAST(${col('b_id')} AS INTEGER), b_name, 
            CAST(${col('c_id')} AS INTEGER), c_name, 
            CAST(${col('v_id')} AS INTEGER), v_name, 
            remarks, 
            CAST(${col('a_id')} AS INTEGER), a_name, 
            CAST(${col('r_id')} AS INTEGER), r_name, 
            CAST(${col('p_id')} AS INTEGER), p_name, 
            ${col('is_grouped', fallback: '0')}, ${col('grouped_ids', fallback: "''")}, 
            CAST(${col('status')} AS INTEGER), j_id, tr_id,
            ${col('stockBalanceId', fallback: '0')},  ${col('stockBalanceQty', fallback: '0')}, 
            ${col('stockBalanceWeight', fallback: '0.0')}, 
            ${col('created_at', fallback: "''")}, ${col('updated_at', fallback: "''")},
            ${col('dbStatus', fallback: "'ACTIVE'")}
        FROM GoodsData_old
      ''');

        // Step D: Clean up
        await txn.execute("DROP TABLE GoodsData_old");
      });
    } else {
      final List<String> columnsToAdd = [
        'list_index INTEGER',
        'created_at TEXT',
        'updated_at TEXT',
        'is_grouped INTEGER',
        'grouped_ids TEXT',
        'status INTEGER',
        'sku_name TEXT',
        'expire_days INTEGER',
        'tray_weight REAL',
        'stockBalanceId INTEGER',
        'stockBalanceQty INTEGER',
        'stockBalanceWeight REAL',
        'dbStatus TEXT DEFAULT \'ACTIVE\''
      ];

      for (var colDef in columnsToAdd) {
        String name = colDef.split(' ')[0];
        if (!goodsColumnName.contains(name)) {
          await db.execute("ALTER TABLE GoodsData ADD COLUMN $colDef");
        }
      }
    }
  }

  // Create the database for goods data
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'dbGoodsData.db');

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        // Run migration check every time DB opens
        await dbColumnUpdate(db);

        // Performance index for job-based goods queries
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_goods_j_id ON GoodsData(j_id)',
        );
      },
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute('CREATE TABLE GoodsData('
            'g_id INTEGER PRIMARY KEY AUTOINCREMENT,' // Goods ID
            'list_index INTEGER,' // Goods list index
            'g_type TEXT,' // Goods Type
            'ct_id INTEGER,' // Goods Category ID
            'ct_name TEXT,' // Goods Category Name
            'pld_id INTEGER,' // Picking List Detail ID
            'j_stattq_maxus TEXT,'
            'gs_id INTEGER,' // Goods SKU ID
            'gs_name TEXT,' // Goods SKU Name
            'sku_name TEXT,' // SKU Display Name
            't_quantity INTEGER,' // Total Quantity
            'tq_max INTEGER,' // Total Quantity Max
            'tqn_max INTEGER,' // Total Quantity New Max
            't_weight REAL,' // Total Weight
            'tw_max REAL,' // Total Weight Max
            'twn_max REAL,' // Total Weight New Max
            'tt_tray INTEGER,' // Total Tray
            'tray_weight REAL,' // Tray Weight
            's_trolley INTEGER,' // Select Trolley
            'st_weight REAL,' // Trolley Weight
            'nt_weight REAL,' // Nett Weight
            'uq_id INTEGER,' // UOM Quantity ID
            'uq_name TEXT,' // UOM Quantity Name
            'uw_id INTEGER,' // UOM Weight ID
            'uw_name TEXT,' // UOM Weight Name
            'q_control INTEGER,' // Quantity Control
            'w_control INTEGER,' // Weight Control
            'sb_id INTEGER,' // Stock Balance ID
            'pb_no TEXT,' // Production Batch No
            'p_date TEXT,' // Production Date
            'e_date TEXT,' // Expiration Date
            'b_id INTEGER,' // Brand ID
            'b_name TEXT,' // Brand Name
            'c_id INTEGER,' // Customer ID
            'c_name TEXT,' // Customer Name
            'v_id INTEGER,' // Vendor ID
            'v_name TEXT,' // Vendor Name
            'remarks TEXT,' // Remarks
            'a_id INTEGER,' // Area ID
            'a_name TEXT,' // Area Name
            'r_id INTEGER,' // Rack ID
            'r_name TEXT,' // Rack Name
            'p_id INTEGER,' // Pallet ID
            'p_name TEXT,' // Pallet Name
            'is_grouped INTEGER,' // SKU IS GROUPED
            'grouped_ids TEXT,' // SKU Group list
            'status INTEGER,' // Status
            'j_id INTEGER,' // Job ID
            'tr_id TEXT,' // Transaction ID
            'created_at TEXT,'
            'updated_at TEXT,'
            'dbStatus TEXT DEFAULT \'ACTIVE\''
            ')');

        // Performance index for job-based goods queries
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_goods_j_id ON GoodsData(j_id)',
        );
      },
      onConfigure: _onConfigure,
    );
  }

  // Insert data into goods data
  Future<int> createGoodsData(GoodsModel newGoodsData) async {
    // Get a reference to the database
    final db = await database;
    int insertedId = await db.insert(
      'GoodsData',
      newGoodsData.toJson(),
    );

    return insertedId;
  }

  Future<void> insertAllGoodsData(List<GoodsModel> newGoodsData) async {
    final db = await database; // Get your database instance
    final batch = db.batch();

    for (var item in newGoodsData) {
      batch.insert(
        'GoodsData',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true); // Executes all inserts at once
  }

  // Get all goods data
  Future<dynamic> getAllGoodsData() async {
    final db = await database;
    // final res = await db.rawQuery("SELECT * FROM GoodsData");
    final res =
        await db.rawQuery("SELECT * FROM GoodsData WHERE dbStatus = 'ACTIVE'");

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get goods data from job id
  Future<dynamic> getAllGoodsDataBasedJobID(int jobID) async {
    final db = await database;
    // final res =
    //     await db.rawQuery("SELECT * FROM GoodsData WHERE j_id = ?", [jobID]);

    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE j_id = ? AND status != ? AND dbStatus = 'ACTIVE' ",
        [jobID, 3]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  Future<dynamic> getAllDeleteGoodsDataBasedJobID(int jobID) async {
    final db = await database;
    // final res =
    //     await db.rawQuery("SELECT * FROM GoodsData WHERE j_id = ?", [jobID]);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE j_id = ? AND dbStatus = ?",
        [jobID, 'DELETED']);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get goods data from job id
  Future<dynamic> getAllGoodsDataBasedJobIDAndTrId(
      int jobID, String transId) async {
    final db = await database;
    // final res = await db.rawQuery(
    //     "SELECT * FROM GoodsData WHERE j_id = ? AND tr_id = ?",
    //     [jobID, transId]);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE j_id = ? AND tr_id = ? AND dbStatus = 'ACTIVE'",
        [jobID, transId]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all goods based on RECEIVE
  Future<dynamic> getAllGoodsDataBasedReceive() async {
    final db = await database;
    // final res = await db
    //     .rawQuery("SELECT * FROM GoodsData WHERE g_type == ?", ['RECEIVE']);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE g_type = ? AND dbStatus = 'ACTIVE'",
        ['RECEIVE']);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all goods based on ISSUES
  Future<dynamic> getAllGoodsDataBasedIssues() async {
    final db = await database;
    // final res = await db
    //     .rawQuery("SELECT * FROM GoodsData WHERE g_type == ?", ['ISSUES']);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE g_type = ? AND dbStatus = 'ACTIVE'",
        ['ISSUES']);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all goods data from goods id
  Future<dynamic> getGoodsDataBasedID(int goodsID) async {
    final db = await database;
    // final res =
    //     await db.rawQuery("SELECT * FROM GoodsData WHERE g_id = ?", [goodsID]);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE g_id = ? AND dbStatus = 'ACTIVE'",
        [goodsID]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all goods data from goods sku
  Future<dynamic> getGoodsDataBasedSKU(String goodsSKU) async {
    final db = await database;
    // final res = await db
    //     .rawQuery("SELECT * FROM GoodsData WHERE gs_name = ?", [goodsSKU]);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE gs_name = ? AND dbStatus = 'ACTIVE'",
        [goodsSKU]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Get all goods data from goods batch
  Future<dynamic> getGoodsDataBasedBatch(
      String goodsBatchID, String goodsSKU) async {
    final db = await database;
    // final res = await db.rawQuery(
    //     "SELECT * FROM GoodsData WHERE sb_id = ? AND gs_name = ?",
    //     [goodsBatchID, goodsSKU]);
    final res = await db.rawQuery(
        "SELECT * FROM GoodsData WHERE sb_id = ? AND gs_name = ? AND dbStatus = 'ACTIVE'",
        [goodsBatchID, goodsSKU]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  Future<int> getGoodsCountByTxn(String transactionID) async {
    final db = await database;
    var result = await db.rawQuery(
        'SELECT COUNT(*) FROM GoodsData WHERE tr_id = ?', [transactionID]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete all goods data
  Future<int> deleteAllGoodsData() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM GoodsData');

    return res;
  }

  // Delete goods based on job id
  Future<int> deleteGoodsBasedJobId(int jobId) async {
    final db = await database;
    final res =
        await db.rawDelete("DELETE FROM GoodsData WHERE j_id = ?", [jobId]);

    return res;
  }

  // Delete goods data from goods id
  Future<dynamic> deleteGoodsDataBasedID(int goodsID) async {
    final db = await database;
    final res =
        await db.rawQuery("DELETE FROM GoodsData WHERE g_id = ?", [goodsID]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  Future<void> deleteGoodsDataBasedIDs(List<dynamic> jobIDs) async {
    if (jobIDs.isEmpty) return;

    final db = await database;

    final placeholders = List.filled(jobIDs.length, '?').join(',');

    await db.delete(
      'GoodsData',
      where: 'j_id IN ($placeholders)',
      whereArgs: jobIDs,
    );
  }

  Future<dynamic> softDeleteGoodsDataBasedID(int goodsID) async {
    final db = await database;

    Map<String, dynamic> updateRow = {
      'dbStatus': 'DELETED',
      'updated_at': DateFormat("yyyy-MM-dd")
          .add_Hms()
          .format(DateTime.now()), // Good practice to track when it was deleted
    };

    return await db.update(
      'GoodsData', // db table name
      updateRow,
      where: 'g_id = ?',
      whereArgs: [goodsID],
    );
  }

  // Delete goods data from goods id
  Future<dynamic> deleteGoodsDataBasedPLID(String transactionID) async {
    final db = await database;
    final res = await db
        .rawQuery("DELETE FROM GoodsData WHERE tr_id = ?", [transactionID]);

    if (res.isNotEmpty) {
      return res;
    }

    return null;
  }

  // Inside your DBGoodsData class
  Future<int?> checkDeletedDuplicate({
    required String goodsType,
    required int goodsCategoryId,
    required int goodsSKUID,
    required int stockBalanceID,
    required String productionBatchNo,
    required String productionDate,
    required String expirationDate,
    required int jobId,
    required String transactionID,
    required int qty,
    required double weight,
  }) async {
    final db = await database;

    final List<Map<String, dynamic>> res = await db.query(
      'GoodsData',
      where:
          'g_type = ? AND ct_id = ? AND gs_id = ? AND sb_id = ? AND pb_no = ? AND p_date = ? AND e_date = ? AND j_id = ? AND tr_id = ? AND dbStatus = ?',

      whereArgs: [
        goodsType,
        goodsCategoryId,
        goodsSKUID,
        stockBalanceID,
        productionBatchNo,
        productionDate,
        expirationDate,
        jobId,
        transactionID,
        'DELETED'
      ],
      limit: 1, // We only care about finding one matching row
    );

    if (res.isEmpty) return null;

    final row = res.first;

    final deletedQty = (row['qty'] ?? 0).toDouble();
    final deletedWeight = (row['weight'] ?? 0).toDouble();

    /// same qty + weight → restore directly
    if (qty == deletedQty && weight == deletedWeight) {
      return row['g_id'] as int;
    }

    /// user add back less than deleted
    if (qty < deletedQty || weight < deletedWeight) {
      return row['g_id'] as int;

      // later update qty/weight inside reactivateGoodsData
    }

    /// user add back more than deleted
    if (qty > deletedQty || weight > deletedWeight) {
      return null;
    }

    return null;

    // if (res.isNotEmpty) {
    //   return res.first['g_id'] as int;
    // }
    // return null;
  }

  // Update selected Job base on ID
  Future<dynamic> updateGoodsData(GoodsModel goodsModel, int goodsId) async {
    final db = await database;
    Map<String, dynamic> row = {
      'g_type': goodsModel.goodsType,
      'ct_id': goodsModel.goodsCategoryId,
      'ct_name': goodsModel.goodsCategoryName,
      'pld_id': goodsModel.plDetailID,
      'gs_id': goodsModel.goodsSKUID,
      'gs_name': goodsModel.goodsSKUName,
      't_quantity': goodsModel.totalQuantity,
      'tq_max': goodsModel.totalQuantityMax,
      'tqn_max': goodsModel.totalQuantityNewMax,
      't_weight': goodsModel.totalWeight,
      'tw_max': goodsModel.totalWeightMax,
      'twn_max': goodsModel.totalWeightNewMax,
      'tt_tray': goodsModel.totalTray,
      's_trolley': goodsModel.selectTrolley,
      'st_weight': goodsModel.trolleyWeight,
      'nt_weight': goodsModel.nettWeight,
      'uq_id': goodsModel.uomQtyID,
      'uq_name': goodsModel.uomQtyName,
      'uw_id': goodsModel.uomWeightID,
      'uw_name': goodsModel.uomWeightName,
      'q_control': goodsModel.qtyControl,
      'w_control': goodsModel.weightControl,
      'sb_id': goodsModel.stockBalanceID,
      'pb_no': goodsModel.productionBatchNo,
      'p_date': goodsModel.productionDate,
      'e_date': goodsModel.expirationDate,
      'b_id': goodsModel.brandId,
      'b_name': goodsModel.brandName,
      'c_id': goodsModel.customerId,
      'c_name': goodsModel.customerName,
      'v_id': goodsModel.vendorId,
      'v_name': goodsModel.vendorName,
      'remarks': goodsModel.remarks,
      'r_id': goodsModel.rackID,
      'r_name': goodsModel.rackName,
      'p_id': goodsModel.palletID,
      'p_name': goodsModel.palletName,
      'tray_weight': goodsModel.trayWeight,
      'is_grouped': goodsModel.isGrouped,
      'grouped_ids': goodsModel.groupId,
      'status': goodsModel.status,
      'j_id': goodsModel.jobId,
      'tr_id': goodsModel.transactionID,
      'stockBalanceId': goodsModel.stockId,
      'stockBalanceQty': goodsModel.stockQty,
      'stockBalanceWeight': goodsModel.stockWeight,
      'created_at': goodsModel.createdAt,
      'updated_at': goodsModel.updatedAt,
      'dbStatus': 'ACTIVE',
    };

    return await db.update(
      'GoodsData', // db table name
      row,
      where: 'g_id = ?',
      whereArgs: [goodsId],
    );
  }

  Future<int> reactivateGoodsData(int goodsId) async {
    final db = await database;

    // // Define exactly which fields are allowed to change during a restoration
    // Map<String, dynamic> dynamicRowData = {
    //   // 't_quantity': goodsModel.totalQuantity,
    //   // 'tq_max': goodsModel.totalQuantityMax,
    //   // 't_weight': goodsModel.totalWeight,
    //   // 'tw_max': goodsModel.totalWeightMax,
    //   // 'tt_tray': goodsModel.totalTray,
    //   // 's_trolley': goodsModel.selectTrolley,
    //   // 'st_weight': goodsModel.trolleyWeight,
    //   // 'nt_weight': goodsModel.nettWeight,
    //   // 'p_id': goodsModel.palletID,
    //   // 'p_name': goodsModel.palletName,
    //   // 'updated_at': goodsModel.updatedAt,
    //   'dbStatus': 'ACTIVE', // Changes status back from 'DELETED'
    // };
    // return await db.update(
    //   'GoodsData',
    //   dynamicRowData,
    //   where: 'g_id = ?',
    //   whereArgs: [goodsId],
    // );

    final result = await db.update(
      'GoodsData',
      {'dbStatus': 'ACTIVE'},
      where: 'g_id = ?',
      whereArgs: [goodsId],
    );

    return result;
  }
}
