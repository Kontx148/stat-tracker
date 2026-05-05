import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static bool _prepared = false;
  sql.Database? _db;

  static void prepare() {
    if (_prepared || kIsWeb) return;
    const desktop = {
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    };
    if (desktop.contains(defaultTargetPlatform)) {
      sqfliteFfiInit();
      sql.databaseFactory = databaseFactoryFfi;
    }
    _prepared = true;
  }

  Future<sql.Database> get instance async => _db ??= await _open();

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<sql.Database> _open() async {
    prepare();
    final file = p.join(await sql.getDatabasesPath(), 'beverage_stats.db');
    return sql.openDatabase(
      file,
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async => _create(db),
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) await _upgradeFromV1(db);
      },
    );
  }

  Future<void> _create(sql.Database db) async {
    await db.execute(
      'CREATE TABLE beverages(id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE, icon_key TEXT NOT NULL, color_value INTEGER NOT NULL, image_asset TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE tracked_beverages(beverage_id INTEGER PRIMARY KEY, created_at TEXT NOT NULL, FOREIGN KEY(beverage_id) REFERENCES beverages(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE consumptions(id INTEGER PRIMARY KEY, beverage_id INTEGER NOT NULL, quantity INTEGER NOT NULL CHECK(quantity>0), consumed_at TEXT NOT NULL, FOREIGN KEY(beverage_id) REFERENCES beverages(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE INDEX idx_consumptions_lookup ON consumptions(beverage_id, consumed_at)',
    );
  }

  Future<void> _upgradeFromV1(sql.Database db) async {
    final columns = (await db.rawQuery(
      'PRAGMA table_info(beverages)',
    )).map((r) => r['name']).toSet();
    if (!columns.contains('icon_key')) {
      await db.execute(
        "ALTER TABLE beverages ADD COLUMN icon_key TEXT NOT NULL DEFAULT 'drink'",
      );
    }
    if (!columns.contains('image_asset')) {
      await db.execute(
        "ALTER TABLE beverages ADD COLUMN image_asset TEXT NOT NULL DEFAULT 'assets/beverages/punch.png'",
      );
    }
    await db.execute(
      'CREATE TABLE IF NOT EXISTS tracked_beverages(beverage_id INTEGER PRIMARY KEY, created_at TEXT NOT NULL, FOREIGN KEY(beverage_id) REFERENCES beverages(id) ON DELETE CASCADE)',
    );
  }
}
