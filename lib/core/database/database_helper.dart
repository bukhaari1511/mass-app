import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

/// Singleton helper class for managing local SQLite database operations.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Products Table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        category TEXT,
        brand TEXT,
        vehicle TEXT,
        model TEXT,
        image_path TEXT,
        cost_price REAL NOT NULL DEFAULT 0.0,
        selling_price REAL NOT NULL DEFAULT 0.0,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        minimum_stock INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Sales Table
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_number TEXT UNIQUE NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0.0,
        payment_method TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Sale Items Table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // 4. Inventory Transactions Table
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reference_id TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Indexes for high performance lookup
    await db.execute('CREATE INDEX idx_products_name ON products (name)');
    await db.execute('CREATE INDEX idx_products_sku ON products (sku)');
    await db.execute('CREATE INDEX idx_products_barcode ON products (barcode)');
    await db.execute('CREATE INDEX idx_sale_items_sale_id ON sale_items (sale_id)');
    await db.execute('CREATE INDEX idx_sale_items_product_id ON sale_items (product_id)');
    await db.execute('CREATE INDEX idx_inventory_transactions_product_id ON inventory_transactions (product_id)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
