import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database instance cleanly
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  runApp(const MassSparePartsApp());
}
