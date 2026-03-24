// lib/core/widgets/custom_button.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.variant = 'primary',
    this.size = 'large',
    this.color,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final String variant;
  final String size;
  final Color? color;
  final IconData? icon;
  final bool fullWidth;

  double get _height {
    switch (size) {
      case 'small':
        return AppDimensions.buttonHeightSM;
      case 'medium':
        return AppDimensions.buttonHeightSM;
      case 'large':
      default:
        return AppDimensions.buttonHeight;
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case 'small':
      case 'medium':
        return AppTextStyles.buttonMedium;
      case 'large':
      default:
        return AppTextStyles.buttonLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    final isDisabled = onTap == null;

    if (variant == 'primary') {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: _height,
        child: ElevatedButton.icon(
          onPressed: isDisabled ? null : (isLoading ? () {} : onTap),
          icon: icon != null && !isLoading
              ? Icon(icon, size: AppDimensions.iconMD)
              : const SizedBox.shrink(),
          label: isLoading
              ? SizedBox(
                  height: AppDimensions.iconMD,
                  width: AppDimensions.iconMD,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDisabled
                          ? AppColors.textTertiary
                          : AppColors.textOnPrimary,
                    ),
                  ),
                )
              : Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDisabled ? buttonColor.withValues(alpha: 0.5) : buttonColor,
            foregroundColor:
                isDisabled ? AppColors.textTertiary : AppColors.textOnPrimary,
            textStyle: _textStyle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),
      );
    } else if (variant == 'outlined') {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: _height,
        child: OutlinedButton.icon(
          onPressed: isDisabled ? null : (isLoading ? () {} : onTap),
          icon: icon != null && !isLoading
              ? Icon(icon, size: AppDimensions.iconMD)
              : const SizedBox.shrink(),
          label: isLoading
              ? SizedBox(
                  height: AppDimensions.iconMD,
                  width: AppDimensions.iconMD,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDisabled ? AppColors.textTertiary : buttonColor,
                    ),
                  ),
                )
              : Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDisabled ? AppColors.textTertiary : buttonColor,
            side: BorderSide(
              color: isDisabled ? AppColors.textTertiary : buttonColor,
              width: 1.5,
            ),
            textStyle: _textStyle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        height: _height,
        child: TextButton.icon(
          onPressed: isDisabled ? null : (isLoading ? () {} : onTap),
          icon: icon != null && !isLoading
              ? Icon(icon, size: AppDimensions.iconMD)
              : const SizedBox.shrink(),
          label: isLoading
              ? SizedBox(
                  height: AppDimensions.iconMD,
                  width: AppDimensions.iconMD,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDisabled ? AppColors.textTertiary : buttonColor,
                    ),
                  ),
                )
              : Text(label),
          style: TextButton.styleFrom(
            foregroundColor: isDisabled ? AppColors.textTertiary : buttonColor,
            textStyle: _textStyle,
          ),
        ),
      );
    }
  }
}
