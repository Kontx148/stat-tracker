import 'package:flutter/material.dart';

import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/stats/data/stat_repository.dart';
import 'shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase.prepare();
  runApp(DrinkApp(repository: StatRepository(AppDatabase())));
}

class DrinkApp extends StatelessWidget {
  const DrinkApp({super.key, required this.repository});
  final StatRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Beverage Stats',
    theme: AppTheme.dark,
    home: AppShell(repository: repository),
  );
}
