import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/product_repository.dart';
import '../../../core/models/product_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_card.dart';
import '../widgets/product_image_widget.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _productRepo = ProductRepository();
  ProductModel? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    final p = await _productRepo.getProductById(widget.productId);

    if (mounted) {
      setState(() {
        _product = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeactivate() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Product?'),
        content: const Text(
          'This product will no longer appear in the active product list. Inventory and sales history will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && _product != null) {
      await _productRepo.deactivateProduct(_product!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${_product!.name}" deactivated.'),
          ),
        );
        Navigator.pop(context, true); // Pop back to list and refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found or has been deleted.')),
      );
    }

    final product = _product!;
    final double estimatedStockValue = product.stockQuantity * product.costPrice;
    final double potentialSalesValue = product.stockQuantity * product.sellingPrice;

    String stockStatusText = 'In Stock';
    Color stockStatusColor = AppColors.success;
    Color stockStatusBg = const Color(0xFFE8F5E9);

    if (product.stockQuantity <= 0) {
      stockStatusText = 'Out of Stock';
      stockStatusColor = AppColors.error;
      stockStatusBg = const Color(0xFFFFEBEE);
    } else if (product.stockQuantity <= product.minimumStock) {
      stockStatusText = 'Low Stock';
      stockStatusColor = AppColors.warning;
      stockStatusBg = const Color(0xFFFFF3E0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Product',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditProductScreen(product: product),
                ),
              );
              if (result == true) {
                _loadProduct();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Deactivate Product',
            onPressed: _confirmDeactivate,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Product Image Header
            Center(
              child: ProductImageWidget(
                imagePath: product.imagePath,
                width: double.infinity,
                height: 220,
                borderRadius: 16,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // Name & Stock Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product.sku ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? stockStatusColor.withAlpha(40) : stockStatusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stockStatusColor.withAlpha(100), width: 1),
                  ),
                  child: Text(
                    stockStatusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: stockStatusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Summary Cards
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Stock Value',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.currency(estimatedStockValue),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${product.stockQuantity} × ${Formatters.currency(product.costPrice)} cost',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Potential Sales Value',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatters.currency(potentialSalesValue),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          '${product.stockQuantity} × ${Formatters.currency(product.sellingPrice)} sell',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detailed Spec Grid
            _buildDetailSectionTitle('Price & Inventory Details', isDark),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Selling Price', Formatters.currency(product.sellingPrice), isDark, isHighlight: true),
                  const Divider(height: 20),
                  _buildDetailRow('Cost Price', Formatters.currency(product.costPrice), isDark),
                  const Divider(height: 20),
                  _buildDetailRow('Current Stock Quantity', '${product.stockQuantity} units', isDark),
                  const Divider(height: 20),
                  _buildDetailRow('Minimum Stock Alert Level', '${product.minimumStock} units', isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle Specs & Compatibility
            _buildDetailSectionTitle('Vehicle Specifications', isDark),
            const SizedBox(height: 10),
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Category', product.category ?? 'Unassigned', isDark),
                  const Divider(height: 20),
                  _buildDetailRow('Brand', product.brand ?? 'N/A', isDark),
                  const Divider(height: 20),
                  _buildDetailRow('Vehicle Compatibility', product.vehicle ?? 'N/A', isDark),
                  const Divider(height: 20),
                  _buildDetailRow('Model / Year', product.model ?? 'N/A', isDark),
                  const Divider(height: 20),
                  _buildDetailRow('Barcode Number', product.barcode ?? 'N/A', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditProductScreen(product: product),
                        ),
                      );
                      if (result == true) {
                        _loadProduct();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Product'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmDeactivate,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Deactivate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight
                ? AppColors.primary
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
