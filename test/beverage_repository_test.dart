import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stat_tracker/core/database/app_database.dart';
import 'package:stat_tracker/features/stats/data/stat_repository.dart';

void main() {
  late Directory tempDir;
  late AppDatabase database;

  setUp(() async {
    sqfliteFfiInit();
    sql.databaseFactory = databaseFactoryFfi;
    tempDir = await Directory.systemTemp.createTemp('stat_tracker_test_');
    await databaseFactoryFfi.setDatabasesPath(tempDir.path);
    database = AppDatabase();
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  test('catalog presets are tracked only after user adds them', () async {
    final repository = BeverageRepository(database);

    final catalog = await repository.catalog();
    expect(catalog.map((b) => b.name), containsAll(['White Monster', 'Ciuc']));
    expect(await repository.tracked(), isEmpty);

    await repository.track(catalog.first.id);
    expect((await repository.tracked()).map((b) => b.id), [catalog.first.id]);
  });
}
