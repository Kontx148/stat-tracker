import '../../../core/database/app_database.dart';
import '../../calendar/domain/day_slice.dart';
import '../domain/stats.dart';
import 'package:sqflite/sqflite.dart' as sql;

class StatRepository {
  StatRepository(this.database);
  final AppDatabase database;
  bool _seeded = false;

  static const images = [
    'assets/beverages/white_monster.png',
    'assets/beverages/normal_monster.png',
    'assets/beverages/punch.png',
    'assets/beverages/heineken.png',
    'assets/beverages/ciuc.png',
    'assets/beverages/harghita.png',
  ];

  static const presets = [
    (
      'White Monster',
      'energy',
      0xfff5f5ed,
      'assets/beverages/white_monster.png',
    ),
    (
      'Normal Monster',
      'soda',
      0xff63ef72,
      'assets/beverages/normal_monster.png',
    ),
    ('Punch', 'drink', 0xffff477e, 'assets/beverages/punch.png'),
    ('Heineken', 'bottle', 0xff28c76f, 'assets/beverages/heineken.png'),
    ('Ciuc', 'bottle', 0xffffa726, 'assets/beverages/ciuc.png'),
    ('Harghita', 'water', 0xff4dabf7, 'assets/beverages/harghita.png'),
  ];

  Future<sql.Database> get _db async {
    final db = await database.instance;
    if (!_seeded) {
      await _seed(db);
      _seeded = true;
    }
    return db;
  }

  Future<void> _seed(sql.Database db) async {
    final batch = db.batch();
    for (final p in presets) {
      batch.insert('beverages', {
        'name': p.$1,
        'icon_key': p.$2,
        'color_value': p.$3,
        'image_asset': p.$4,
      }, conflictAlgorithm: sql.ConflictAlgorithm.ignore);
      batch.update(
        'beverages',
        {'icon_key': p.$2, 'color_value': p.$3, 'image_asset': p.$4},
        where: 'name=?',
        whereArgs: [p.$1],
      );
    }
    await batch.commit(noResult: true);
    await db.rawInsert(
      "INSERT OR IGNORE INTO tracked_beverages(beverage_id,created_at) SELECT id,datetime('now') FROM beverages WHERE name NOT IN (${List.filled(presets.length, '?').join(',')})",
      presets.map((p) => p.$1).toList(),
    );
  }

  Future<List<Stat>> catalog() async => _query(trackedOnly: false);
  Future<List<Stat>> tracked() async => _query(trackedOnly: true);

  Future<List<Stat>> _query({required bool trackedOnly}) async {
    final rows = await (await _db).rawQuery(
      '''
      SELECT b.id,b.name,b.icon_key,b.color_value,b.image_asset,
      CASE WHEN t.beverage_id IS NULL THEN 0 ELSE 1 END tracked,
      COALESCE(SUM(c.quantity),0) total,MAX(c.consumed_at) last
      FROM beverages b
      LEFT JOIN tracked_beverages t ON t.beverage_id=b.id
      LEFT JOIN consumptions c ON c.beverage_id=b.id
      WHERE (?=0 OR t.beverage_id IS NOT NULL)
      GROUP BY b.id
      ORDER BY tracked ASC,b.id DESC
    ''',
      [trackedOnly ? 1 : 0],
    );
    return rows.map(_bev).toList();
  }

  Stat _bev(Map<String, Object?> r) => Stat(
    id: r['id'] as int,
    name: r['name'] as String,
    iconKey: r['icon_key'] as String,
    colorValue: r['color_value'] as int,
    imageAsset: r['image_asset'] as String,
    tracked: (r['tracked'] as int) == 1,
    total: r['total'] as int,
    last: r['last'] == null ? null : DateTime.parse(r['last'] as String),
  );

  Future<void> track(int id) async => (await _db).insert('tracked_beverages', {
    'beverage_id': id,
    'created_at': DateTime.now().toIso8601String(),
  }, conflictAlgorithm: sql.ConflictAlgorithm.ignore);
  Future<void> createAndTrack(
    String name,
    String icon,
    int color,
    String image,
  ) async {
    final id = await (await _db).insert('beverages', {
      'name': name,
      'icon_key': icon,
      'color_value': color,
      'image_asset': image,
    });
    await track(id);
  }

  Future<void> update(
    Stat b,
    String name,
    String icon,
    int color,
    String image,
  ) async => (await _db).update(
    'beverages',
    {
      'name': name,
      'icon_key': icon,
      'color_value': color,
      'image_asset': image,
    },
    where: 'id=?',
    whereArgs: [b.id],
  );
  Future<void> addStat(int id) async => (await _db).insert('consumptions', {
    'beverage_id': id,
    'quantity': 1,
    'consumed_at': DateTime.now().toIso8601String(),
  });
  Future<void> removeStat(int id) async {
    final rows = await (await _db).query(
      'consumptions',
      where: 'beverage_id=?',
      whereArgs: [id],
      orderBy: 'consumed_at DESC,id DESC',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      await (await _db).delete(
        'consumptions',
        where: 'id=?',
        whereArgs: [rows.first['id']],
      );
    }
  }

  Future<Map<String, List<DaySlice>>> week() async {
    final rows = await (await _db).rawQuery(
      '''
      SELECT substr(c.consumed_at,1,10) day,b.name,b.color_value,SUM(c.quantity) quantity
      FROM consumptions c JOIN beverages b ON b.id=c.beverage_id
      WHERE substr(c.consumed_at,1,10)>=? GROUP BY day,b.id ORDER BY day,b.id
    ''',
      [dayKey(DateTime.now().subtract(const Duration(days: 6)))],
    );
    final map = <String, List<DaySlice>>{};
    for (final r in rows) {
      map
          .putIfAbsent(r['day'] as String, () => [])
          .add(
            DaySlice(
              r['name'] as String,
              r['color_value'] as int,
              r['quantity'] as int,
            ),
          );
    }
    return map;
  }
}
