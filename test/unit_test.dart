import 'package:flutter_test/flutter_test.dart';
import 'package:mass_spare_parts/core/models/product_model.dart';
import 'package:mass_spare_parts/core/utils/formatters.dart';

void main() {
  group('ProductModel & Formatters Tests', () {
    test('ProductModel calculate total inventory value and low stock status', () {
      final product = ProductModel(
        name: 'Bajaj Pulsar Brake Pad',
        costPrice: 15.0,
        sellingPrice: 25.0,
        stockQuantity: 2,
        minimumStock: 5,
      );

      expect(product.totalInventoryValue, 30.0);
      expect(product.isLowStock, isTrue);
    });

    test('Formatters currency and number formatting', () {
      expect(Formatters.currency(1250.5), '\$1,250.50');
      expect(Formatters.number(1000), '1,000');
    });
  });
}
