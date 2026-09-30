class InventoryTransactionModel {
  final int? id;
  final int productId;
  final String? productName;
  final String transactionType; // 'IN', 'OUT', 'ADJUSTMENT'
  final int quantity;
  final String? referenceId;
  final String? note;
  final DateTime createdAt;

  InventoryTransactionModel({
    this.id,
    required this.productId,
    this.productName,
    required this.transactionType,
    required this.quantity,
    this.referenceId,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'transaction_type': transactionType,
      'quantity': quantity,
      'reference_id': referenceId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InventoryTransactionModel.fromMap(Map<String, dynamic> map) {
    return InventoryTransactionModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String?,
      transactionType: map['transaction_type'] as String? ?? 'IN',
      quantity: (map['quantity'] as num).toInt(),
      referenceId: map['reference_id'] as String?,
      note: map['note'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
