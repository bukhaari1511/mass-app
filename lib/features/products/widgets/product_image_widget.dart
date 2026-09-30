import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Renders local product image safely from storage path.
/// Displays fallback placeholder icon if file does not exist or image path is empty.
class ProductImageWidget extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    this.imagePath,
    this.width = 64,
    this.height = 64,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasValidFile = imagePath != null &&
        imagePath!.trim().isNotEmpty &&
        File(imagePath!).existsSync();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: hasValidFile
            ? Image.file(
                File(imagePath!),
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDark),
              )
            : _buildPlaceholder(isDark),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: Icon(
        Icons.settings_suggest_outlined,
        size: width * 0.45,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
      ),
    );
  }
}
