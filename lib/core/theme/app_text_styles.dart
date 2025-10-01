import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FODO App Text Styles
/// 
/// Comprehensive typography system ensuring optimal readability
/// and visual hierarchy throughout the application.
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // DISPLAY TEXT STYLES (Largest)
  // ============================================
  
  /// Display Large - Hero text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Display Medium - Large headers
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.25,
  );
  
  /// Display Small - Section headers
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ============================================
  // HEADLINE TEXT STYLES
  // ============================================
  
  /// Headline Large - Page titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Headline Medium - Card titles
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Headline Small - Subsection titles
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ============================================
  // TITLE TEXT STYLES
  // ============================================
  
  /// Title Large - Dialog titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Title Medium - List item titles
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );
  
  /// Title Small - Small titles
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // ============================================
  // BODY TEXT STYLES
  // ============================================
  
  /// Body Large - Emphasized body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.6,
    letterSpacing: 0.5,
  );
  
  /// Body Medium - Regular body text
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  /// Body Small - Small body text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // ============================================
  // LABEL TEXT STYLES
  // ============================================
  
  /// Label Large - Button text, form labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  /// Label Medium - Small button text
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: 0.5,
  );
  
  /// Label Small - Tiny labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  // ============================================
  // SPECIALIZED TEXT STYLES
  // ============================================
  
  /// Button Text - Primary button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Button Text Small - Small button text
  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.3,
  );
  
  /// Caption - Image captions, timestamps
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.4,
  );
  
  /// Overline - Labels, tags
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  /// Number Large - Statistics, counts
  static const TextStyle numberLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGreen,
    height: 1,
    letterSpacing: -1,
  );
  
  /// Number Medium - Counts, metrics
  static const TextStyle numberMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGreen,
    height: 1,
    letterSpacing: -0.5,
  );
  
  /// Number Small - Small counts
  static const TextStyle numberSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryGreen,
    height: 1,
  );

  // ============================================
  // STATUS TEXT STYLES
  // ============================================
  
  /// Status Active - Active status badge
  static const TextStyle statusActive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Status Warning - Warning status badge
  static const TextStyle statusWarning = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.warning,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Status Error - Error status badge
  static const TextStyle statusError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Create text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Create text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Create text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// Create text style for status
  static TextStyle getStatusTextStyle(String status) {
    final color = AppColors.getStatusColor(status);
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.2,
      letterSpacing: 0.5,
    );
  }
  
  /// Create white text variant
  static TextStyle toWhite(TextStyle style) {
    return style.copyWith(color: AppColors.white);
  }
  
  /// Create green text variant
  static TextStyle toGreen(TextStyle style) {
    return style.copyWith(color: AppColors.primaryGreen);
  }
  
  /// Create secondary text variant
  static TextStyle toSecondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }
}
