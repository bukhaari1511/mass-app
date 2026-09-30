class SaleItemModel {
  final int? id;
  final int? saleId;
  final int productId;
  final String? productName; // Optional joined field for UI convenience
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  SaleItemModel({
    this.id,
    this.saleId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    double? totalPrice,
  }) : totalPrice = totalPrice ?? (quantity * unitPrice);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'] as int?,
      saleId: map['sale_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String?,
      quantity: (map['quantity'] as num).toInt(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }
}
