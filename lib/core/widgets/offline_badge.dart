import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Status badge indicator displaying "● Offline" to highlight local offline-first architecture.
class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.offlineGreen.withAlpha(50)
            : AppColors.offlineGreenBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.offlineGreen.withAlpha(100),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.offlineGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              color: isDark ? const Color(0xFF81C784) : AppColors.offlineGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
