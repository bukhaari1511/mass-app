import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/product_repository.dart';
import '../../../core/models/product_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../widgets/product_image_widget.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepository _productRepo = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  int _activeCount = 0;
  bool _isLoading = true;
  String _selectedFilter = 'All';

  // Strictly specified filters per requirement
  final List<String> _filterOptions = [
    'All',
    'Cars',
    'Bajaj',
    'Low Stock',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _productRepo.getProducts(
          searchQuery: _searchController.text,
          filter: _selectedFilter,
        ),
        _productRepo.getActiveProductCount(),
      ]);

      if (mounted) {
        setState(() {
          _products = results[0] as List<ProductModel>;
          _activeCount = results[1] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _loadProducts();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadProducts();
  }

  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditProductScreen(),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _navigateToDetail(ProductModel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id!),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Products'),
            Text(
              '$_activeCount active ${_activeCount == 1 ? 'spare part' : 'spare parts'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _navigateToAddProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Product',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products by name, SKU, barcode, brand...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
            ),
          ),

          // Horizontal Filter Chips (All, Cars, Bajaj, Low Stock, Out of Stock)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _onFilterSelected(filter);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Main Product List / Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: 'No products yet',
                              subtitle: 'Add your first spare part to start managing your inventory.',
                              action: ElevatedButton.icon(
                                onPressed: _navigateToAddProduct,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  'Add Product',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return _buildProductCard(product, isDark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, bool isDark) {
    String statusText = 'In Stock';
    Color statusColor = AppColors.success;
    Color statusBg = const Color(0xFFE8F5E9);

    if (product.stockQuantity <= 0) {
      statusText = 'Out of Stock';
      statusColor = AppColors.error;
      statusBg = const Color(0xFFFFEBEE);
    } else if (product.stockQuantity <= product.minimumStock) {
      statusText = 'Low Stock';
      statusColor = AppColors.warning;
      statusBg = const Color(0xFFFFF3E0);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        onTap: () => _navigateToDetail(product),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image Thumbnail
            ProductImageWidget(
              imagePath: product.imagePath,
              width: 72,
              height: 72,
              borderRadius: 12,
            ),
            const SizedBox(width: 14),

            // Main Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'SKU: ${product.sku ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      if (product.category != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${product.category}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.currency(product.sellingPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? statusColor.withAlpha(40) : statusBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$statusText (${product.stockQuantity})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
