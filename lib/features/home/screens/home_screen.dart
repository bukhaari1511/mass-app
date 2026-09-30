import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/product_repository.dart';
import '../../../core/database/sales_repository.dart';
import '../../../core/models/product_model.dart';
import '../../../core/models/sale_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/offline_badge.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _productRepo = ProductRepository();
  final SalesRepository _salesRepo = SalesRepository();

  bool _isLoading = true;
  double _todaySales = 0.0;
  int _todayTransactions = 0;
  double _inventoryValue = 0.0;
  int _lowStockCount = 0;

  List<SaleModel> _recentSales = [];
  List<ProductModel> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _salesRepo.getTodaySalesTotal(),
        _salesRepo.getTodaySalesCount(),
        _productRepo.getTotalInventoryValue(),
        _productRepo.getLowStockCount(),
        _salesRepo.getRecentSales(limit: 5),
        _productRepo.getLowStockProducts(limit: 5),
      ]);

      if (mounted) {
        setState(() {
          _todaySales = results[0] as double;
          _todayTransactions = results[1] as int;
          _inventoryValue = results[2] as double;
          _lowStockCount = results[3] as int;
          _recentSales = results[4] as List<SaleModel>;
          _lowStockProducts = results[5] as List<ProductModel>;
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

  void _showQuickActionNotice(String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionTitle feature will be implemented in Prompt #2.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: const [
                Text(
                  'MASS SPARE PARTS',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(width: 8),
                OfflineBadge(),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Bajaj & Auto Spare Parts',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: _loadDashboardData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: 4 Summary Cards Grid
                    _buildSummaryGrid(isDark),
                    const SizedBox(height: 24),

                    // Section 2: Quick Actions
                    _buildSectionHeader('Quick Actions', isDark),
                    const SizedBox(height: 12),
                    _buildQuickActions(isDark),
                    const SizedBox(height: 24),

                    // Section 3: Recent Sales
                    _buildSectionHeader('Recent Sales', isDark),
                    const SizedBox(height: 12),
                    _buildRecentSalesSection(isDark),
                    const SizedBox(height: 24),

                    // Section 4: Low Stock
                    _buildSectionHeader('Low Stock', isDark),
                    const SizedBox(height: 12),
                    _buildLowStockSection(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  /// 4 Summary Cards Layout (2x2 Grid)
  Widget _buildSummaryGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildMetricCard(
          title: "Today's Sales",
          value: Formatters.currency(_todaySales),
          icon: Icons.payments_outlined,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryContainer.withAlpha(150),
          isDark: isDark,
        ),
        _buildMetricCard(
          title: "Transactions",
          value: "${Formatters.number(_todayTransactions)} sales",
          icon: Icons.receipt_long_outlined,
          iconColor: const Color(0xFF0288D1),
          iconBgColor: const Color(0xFFE1F5FE),
          isDark: isDark,
        ),
        _buildMetricCard(
          title: "Inventory Value",
          value: Formatters.currency(_inventoryValue),
          icon: Icons.inventory_2_outlined,
          iconColor: const Color(0xFF7B1FA2),
          iconBgColor: const Color(0xFFF3E5F5),
          isDark: isDark,
        ),
        _buildMetricCard(
          title: "Low Stock",
          value: "${Formatters.number(_lowStockCount)} items",
          icon: Icons.warning_amber_rounded,
          iconColor: _lowStockCount > 0 ? AppColors.error : AppColors.textSecondary,
          iconBgColor: _lowStockCount > 0 ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
          isDark: isDark,
          highlight: _lowStockCount > 0,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isDark,
    bool highlight = false,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      border: highlight
          ? Border.all(color: AppColors.error.withAlpha(150), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withAlpha(40) : iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: highlight && !isDark
                    ? AppColors.error
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Action Grid (2x2)
  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildActionButton(
                label: 'New Sale',
                subtitle: 'Process order',
                icon: Icons.add_shopping_cart,
                color: AppColors.primary,
                onTap: () => _showQuickActionNotice('New Sale'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                label: 'Receive Stock',
                subtitle: 'Add inventory',
                icon: Icons.input,
                color: const Color(0xFF00897B),
                onTap: () => _showQuickActionNotice('Receive Stock'),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _buildActionButton(
                label: 'Products',
                subtitle: 'View catalog',
                icon: Icons.category_outlined,
                color: const Color(0xFF1976D2),
                onTap: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(1); // Products Tab
                  }
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                label: 'Inventory',
                subtitle: 'Manage stock',
                icon: Icons.warehouse_outlined,
                color: const Color(0xFF7E57C2),
                onTap: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(3); // Inventory Tab
                  }
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 50 : 25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Sales List / Empty State
  Widget _buildRecentSalesSection(bool isDark) {
    if (_recentSales.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_outlined,
        title: 'No sales yet',
        subtitle: 'Transactions completed today will appear here.',
      );
    }

    return Column(
      children: _recentSales.map((sale) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryContainer.withAlpha(120),
                      child: const Icon(Icons.point_of_sale, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.saleNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${sale.paymentMethod} • ${Formatters.formatTime(sale.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  Formatters.currency(sale.totalAmount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Low Stock List / Empty State
  Widget _buildLowStockSection(bool isDark) {
    if (_lowStockProducts.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No low-stock products',
        subtitle: 'All product inventory levels are above minimum thresholds.',
      );
    }

    return Column(
      children: _lowStockProducts.map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: Border.all(color: AppColors.error.withAlpha(80), width: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFFFEBEE),
                      child: const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.error),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          product.category ?? 'General Spare Parts',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.stockQuantity} in stock (Min: ${product.minimumStock})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
