import 'sale_item_model.dart';

class SaleModel {
  final int? id;
  final String saleNumber;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final List<SaleItemModel> items;

  SaleModel({
    this.id,
    required this.saleNumber,
    required this.totalAmount,
    required this.paymentMethod,
    DateTime? createdAt,
    this.items = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sale_number': saleNumber,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, {List<SaleItemModel> items = const []}) {
    return SaleModel(
      id: map['id'] as int?,
      saleNumber: map['sale_number'] as String? ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: items,
    );
  }
}
