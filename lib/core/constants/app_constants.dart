/// Application constants for Mass Spare Parts.
class AppConstants {
  static const String appName = 'MASS SPARE PARTS';
  static const String appSubtitle = 'Bajaj & Auto Spare Parts';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'mass_spare_parts.db';
  static const int dbVersion = 1;

  // Supported Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'EVC Plus',
    'Zaad',
    'Sahal',
  ];

  // Strictly TWO Categories per prompt specification
  static const List<String> defaultCategories = [
    'Cars',
    'Bajaj',
  ];
}
