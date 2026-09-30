import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/offline_badge.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Header Info
          CustomCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.build_circle_outlined, size: 32, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        AppConstants.appSubtitle,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      const OfflineBadge(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // QuickBooks Accounting Note
          CustomCard(
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
              width: 1,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Accounting Note',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'QuickBooks Desktop remains the primary accounting system. This offline mobile app handles daily shop operations.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Sections
          _buildMenuTile(
            context,
            icon: Icons.bar_chart,
            title: 'Reports & Analytics',
            subtitle: 'Sales reports and inventory summaries',
            onTap: () => _showNotice(context, 'Reports'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.payments_outlined,
            title: 'Payment Methods',
            subtitle: 'Cash, EVC Plus, Zaad, Sahal',
            onTap: () => _showPaymentMethodsDialog(context),
          ),
          _buildMenuTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Local SQLite database backup',
            onTap: () => _showNotice(context, 'Backup & Restore'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.file_download_outlined,
            title: 'Excel Export',
            subtitle: 'Export products & sales to Excel',
            onTap: () => _showNotice(context, 'Excel Export'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Version ${AppConstants.appVersion} • Offline SQLite',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isDark ? AppColors.darkTextPrimary : AppColors.secondary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be implemented in subsequent steps.')),
    );
  }

  void _showPaymentMethodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supported Payment Methods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AppConstants.paymentMethods.map((pm) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(pm, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mass Spare Parts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Version: 1.0.0 (Foundation)'),
            SizedBox(height: 6),
            Text('Target: Bajaj & Auto Spare Parts Shop'),
            SizedBox(height: 6),
            Text('Database: Offline SQLite (sqflite)'),
            SizedBox(height: 6),
            Text('Framework: Flutter + Dart'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
