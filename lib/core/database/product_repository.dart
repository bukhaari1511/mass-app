import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';
import 'database_helper.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper;

  ProductRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fetch active products with optional live search and category/stock filter.
  Future<List<ProductModel>> getProducts({
    String? searchQuery,
    String? filter = 'All',
  }) async {
    try {
      final db = await _dbHelper.database;
      List<String> whereClauses = ['is_active = 1'];
      List<dynamic> whereArgs = [];

      // Category / Stock Filter logic
      if (filter == 'Bajaj') {
        whereClauses.add('(category = ? OR category LIKE ? OR vehicle LIKE ?)');
        whereArgs.addAll(['Bajaj', '%Bajaj%', '%Bajaj%']);
      } else if (filter == 'Cars') {
        whereClauses.add('(category = ? OR category LIKE ? OR vehicle LIKE ? OR category NOT LIKE ?)');
        whereArgs.addAll(['Cars', '%Car%', '%Car%', '%Bajaj%']);
      } else if (filter == 'Low Stock') {
        whereClauses.add('stock_quantity <= minimum_stock AND stock_quantity > 0');
      } else if (filter == 'Out of Stock') {
        whereClauses.add('stock_quantity <= 0');
      }

      // Live Search query matching
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryPattern = '%${searchQuery.trim()}%';
        whereClauses.add(
          '(name LIKE ? OR sku LIKE ? OR barcode LIKE ? OR brand LIKE ? OR vehicle LIKE ? OR model LIKE ?)',
        );
        whereArgs.addAll([
          queryPattern,
          queryPattern,
          queryPattern,
          queryPattern,
          queryPattern,
          queryPattern,
        ]);
      }

      final whereString = whereClauses.join(' AND ');

      final result = await db.query(
        'products',
        where: whereString,
        whereArgs: whereArgs,
        orderBy: 'updated_at DESC, name ASC',
      );

      return result.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get count of all active products.
  Future<int> getActiveProductCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM products WHERE is_active = 1');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if a SKU already exists among active products (case-insensitive).
  Future<bool> isSkuExists(String sku, {int? excludeId}) async {
    try {
      final db = await _dbHelper.database;
      String whereClause = 'LOWER(sku) = LOWER(?) AND is_active = 1';
      List<dynamic> whereArgs = [sku.trim()];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final result = await db.query(
        'products',
        columns: ['id'],
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get single product by ID.
  Future<ProductModel?> getProductById(int id) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isNotEmpty) {
        return ProductModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Insert a new product into SQLite and record initial stock in inventory_transactions if stock > 0.
  Future<int> insertProduct(ProductModel product) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      final nowStr = DateTime.now().toIso8601String();
      final map = product.toMap();
      map['created_at'] = nowStr;
      map['updated_at'] = nowStr;
      map['is_active'] = 1;

      final productId = await txn.insert('products', map);

      // Create opening stock inventory transaction if initial stock > 0
      if (product.stockQuantity > 0) {
        await txn.insert('inventory_transactions', {
          'product_id': productId,
          'transaction_type': 'opening_stock',
          'quantity': product.stockQuantity,
          'reference_id': 'INIT-$productId',
          'note': 'Initial opening stock',
          'created_at': nowStr,
        });
      }

      return productId;
    });
  }

  /// Update an existing product's metadata in SQLite (stock_quantity is preserved).
  Future<int> updateProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    final nowStr = DateTime.now().toIso8601String();

    final Map<String, dynamic> updateData = {
      'name': product.name,
      'sku': product.sku,
      'barcode': product.barcode,
      'category': product.category,
      'brand': product.brand,
      'vehicle': product.vehicle,
      'model': product.model,
      'image_path': product.imagePath,
      'cost_price': product.costPrice,
      'selling_price': product.sellingPrice,
      'minimum_stock': product.minimumStock,
      'updated_at': nowStr,
    };

    return await db.update(
      'products',
      updateData,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Soft delete / deactivate a product by setting is_active = 0.
  Future<int> deactivateProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'products',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calculate total inventory valuation: SUM(stock_quantity * cost_price) for active products.
  Future<double> getTotalInventoryValue() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(stock_quantity * cost_price) as total_val 
        FROM products 
        WHERE is_active = 1
      ''');
      if (result.isNotEmpty && result.first['total_val'] != null) {
        return (result.first['total_val'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get count of products at or below minimum stock level.
  Future<int> getLowStockCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM products 
        WHERE is_active = 1 AND stock_quantity <= minimum_stock
      ''');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Fetch products that are at or below minimum stock limit.
  Future<List<ProductModel>> getLowStockProducts({int limit = 10}) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'products',
        where: 'is_active = ? AND stock_quantity <= minimum_stock',
        whereArgs: [1],
        orderBy: 'stock_quantity ASC',
        limit: limit,
      );
      return result.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }
}
