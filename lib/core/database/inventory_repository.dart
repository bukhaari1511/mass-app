import '../models/inventory_transaction_model.dart';
import 'database_helper.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper;

  InventoryRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Log an inventory movement transaction (IN, OUT, ADJUSTMENT).
  Future<int> addTransaction(InventoryTransactionModel transaction) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      final id = await txn.insert('inventory_transactions', transaction.toMap());

      // Update product stock based on transaction type
      if (transaction.transactionType == 'IN') {
        await txn.rawUpdate('''
          UPDATE products 
          SET stock_quantity = stock_quantity + ?, updated_at = ?
          WHERE id = ?
        ''', [transaction.quantity, DateTime.now().toIso8601String(), transaction.productId]);
      } else if (transaction.transactionType == 'OUT') {
        await txn.rawUpdate('''
          UPDATE products 
          SET stock_quantity = stock_quantity - ?, updated_at = ?
          WHERE id = ?
        ''', [transaction.quantity, DateTime.now().toIso8601String(), transaction.productId]);
      } else if (transaction.transactionType == 'ADJUSTMENT') {
        await txn.rawUpdate('''
          UPDATE products 
          SET stock_quantity = ?, updated_at = ?
          WHERE id = ?
        ''', [transaction.quantity, DateTime.now().toIso8601String(), transaction.productId]);
      }

      return id;
    });
  }

  /// Get recent inventory transactions.
  Future<List<InventoryTransactionModel>> getRecentTransactions({int limit = 10}) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('''
        SELECT it.*, p.name as product_name
        FROM inventory_transactions it
        LEFT JOIN products p ON it.product_id = p.id
        ORDER BY it.created_at DESC
        LIMIT ?
      ''', [limit]);

      return result.map((map) => InventoryTransactionModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }
}
