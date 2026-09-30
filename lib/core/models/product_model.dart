class ProductModel {
  final int? id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? category;
  final String? brand;
  final String? vehicle;
  final String? model;
  final String? imagePath;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minimumStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.category,
    this.brand,
    this.vehicle,
    this.model,
    this.imagePath,
    this.costPrice = 0.0,
    this.sellingPrice = 0.0,
    this.stockQuantity = 0,
    this.minimumStock = 0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isLowStock => stockQuantity <= minimumStock;

  double get totalInventoryValue => stockQuantity * costPrice;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'brand': brand,
      'vehicle': vehicle,
      'model': model,
      'image_path': imagePath,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'minimum_stock': minimumStock,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      sku: map['sku'] as String?,
      barcode: map['barcode'] as String?,
      category: map['category'] as String?,
      brand: map['brand'] as String?,
      vehicle: map['vehicle'] as String?,
      model: map['model'] as String?,
      imagePath: map['image_path'] as String?,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (map['stock_quantity'] as num?)?.toInt() ?? 0,
      minimumStock: (map['minimum_stock'] as num?)?.toInt() ?? 0,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? barcode,
    String? category,
    String? brand,
    String? vehicle,
    String? model,
    String? imagePath,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? minimumStock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      vehicle: vehicle ?? this.vehicle,
      model: model ?? this.model,
      imagePath: imagePath ?? this.imagePath,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumStock: minimumStock ?? this.minimumStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
