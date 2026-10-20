import 'package:flutter/material.dart';

import 'db/database_helper.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.database});

  final DatabaseHelper? database;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Catatan',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: HomeScreen(database: database ?? DatabaseHelper.instance),
  );
}
