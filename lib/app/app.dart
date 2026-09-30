import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/main_layout.dart';

class MassSparePartsApp extends StatelessWidget {
  const MassSparePartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mass Spare Parts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default light theme per prompt
      home: const MainLayout(),
    );
  }
}
