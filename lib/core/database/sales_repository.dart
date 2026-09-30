import 'package:sqflite/sqflite.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import 'database_helper.dart';

class SalesRepository {
  final DatabaseHelper _dbHelper;

  SalesRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Get total sales amount for today.
  Future<double> getTodaySalesTotal() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final result = await db.rawQuery('''
        SELECT SUM(total_amount) as today_total
        FROM sales
        WHERE created_at >= ? AND created_at <= ?
      ''', [startOfDay, endOfDay]);

      if (result.isNotEmpty && result.first['today_total'] != null) {
        return (result.first['today_total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get count of transactions completed today.
  Future<int> getTodaySalesCount() async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final result = await db.rawQuery('''
        SELECT COUNT(*) as today_count
        FROM sales
        WHERE created_at >= ? AND created_at <= ?
      ''', [startOfDay, endOfDay]);

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Fetch recent sales records with their item counts.
  Future<List<SaleModel>> getRecentSales({int limit = 5}) async {
    try {
      final db = await _dbHelper.database;
      final salesMap = await db.query(
        'sales',
        orderBy: 'created_at DESC, id DESC',
        limit: limit,
      );

      List<SaleModel> salesList = [];
      for (var map in salesMap) {
        final saleId = map['id'] as int;
        // Optionally fetch items for this sale
        final itemsMap = await db.rawQuery('''
          SELECT si.*, p.name as product_name
          FROM sale_items si
          LEFT JOIN products p ON si.product_id = p.id
          WHERE si.sale_id = ?
        ''', [saleId]);

        final items = itemsMap.map((iMap) => SaleItemModel.fromMap(iMap)).toList();
        salesList.add(SaleModel.fromMap(map, items: items));
      }
      return salesList;
    } catch (e) {
      return [];
    }
  }

  /// Record a new sale with transaction line items.
  Future<int> insertSale(SaleModel sale) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      final saleId = await txn.insert('sales', sale.toMap());

      for (var item in sale.items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
        });

        // Deduct inventory stock
        await txn.rawUpdate('''
          UPDATE products 
          SET stock_quantity = stock_quantity - ?, updated_at = ?
          WHERE id = ?
        ''', [item.quantity, DateTime.now().toIso8601String(), item.productId]);
      }
      return saleId;
    });
  }
}
