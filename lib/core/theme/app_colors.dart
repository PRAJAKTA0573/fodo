import 'package:flutter/material.dart';

/// FODO App Colors - White & Green Design Philosophy
/// 
/// Inspired by professional academic design, adapted for food donation's
/// nature-focused mission. The green conveys growth, sustainability, and
/// environmental consciousness while white ensures content clarity.
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY GREEN PALETTE
  // ============================================
  
  /// Primary Green - Main brand color (#059669)
  /// Used for: Logo, primary buttons, navigation, key interactive elements
  /// Conveys: Trust, sustainability, growth, environmental consciousness
  static const Color primaryGreen = Color(0xFF059669);
  
  /// Primary Green Light - Lighter variant (#10b981)
  /// Used for: Hover states, lighter accents, gradients
  static const Color primaryGreenLight = Color(0xFF10b981);
  
  /// Primary Green Dark - Darker variant (#047857)
  /// Used for: Active states, pressed buttons, emphasis
  static const Color primaryGreenDark = Color(0xFF047857);
  
  /// Primary Green Lighter - Very light (#d1fae5)
  /// Used for: Backgrounds, subtle highlights, cards
  static const Color primaryGreenLighter = Color(0xFFd1fae5);
  
  /// Primary Green Accent - Vibrant (#34d399)
  /// Used for: Success indicators, positive feedback
  static const Color primaryGreenAccent = Color(0xFF34d399);

  // ============================================
  // WHITE FOUNDATION
  // ============================================
  
  /// Pure White - Main background (#ffffff)
  /// Used for: Cards, containers, modal backgrounds
  static const Color white = Color(0xFFffffff);
  
  /// Off White - Subtle background (#f8f9fa)
  /// Used for: Page backgrounds, section dividers
  static const Color offWhite = Color(0xFFf8f9fa);
  
  /// Light Grey - Very light (#f3f4f6)
  /// Used for: Disabled states, borders, dividers
  static const Color lightGrey = Color(0xFFf3f4f6);
  
  /// Grey - Medium grey (#e5e7eb)
  /// Used for: Inactive elements, secondary borders
  static const Color grey = Color(0xFFe5e7eb);

  // ============================================
  // TYPOGRAPHY COLORS
  // ============================================
  
  /// Text Primary - Dark grey (#1f2937)
  /// Used for: Main content, headers, important text
  static const Color textPrimary = Color(0xFF1f2937);
  
  /// Text Secondary - Medium grey (#6b7280)
  /// Used for: Secondary text, descriptions, captions
  static const Color textSecondary = Color(0xFF6b7280);
  
  /// Text Tertiary - Light grey (#9ca3af)
  /// Used for: Placeholders, disabled text, hints
  static const Color textTertiary = Color(0xFF9ca3af);
  
  /// Text On Primary - White
  /// Used for: Text on green backgrounds
  static const Color textOnPrimary = Color(0xFFffffff);

  // ============================================
  // ACCENT COLORS
  // ============================================
  
  /// Success Green - Confirmation (#10b981)
  /// Used for: Success messages, completed states
  static const Color success = Color(0xFF10b981);
  
  /// Warning Orange - Caution (#f59e0b)
  /// Used for: Warnings, pending states, alerts
  static const Color warning = Color(0xFFf59e0b);
  
  /// Error Red - Problems (#ef4444)
  /// Used for: Errors, validation issues, critical alerts
  static const Color error = Color(0xFFef4444);
  
  /// Info Blue - Information (#3b82f6)
  /// Used for: Info messages, tips, secondary actions
  static const Color info = Color(0xFF3b82f6);
  
  /// Purple - Special features (#7c3aed)
  /// Used for: Premium features, special badges
  static const Color purple = Color(0xFF7c3aed);

  // ============================================
  // DARK MODE COLORS
  // ============================================
  
  /// Dark Background - Deep dark (#0f172a)
  /// Used for: Dark mode backgrounds
  static const Color darkBackground = Color(0xFF0f172a);
  
  /// Dark Surface - Lighter dark (#1e293b)
  /// Used for: Dark mode cards, elevated surfaces
  static const Color darkSurface = Color(0xFF1e293b);
  
  /// Dark Border - Dark grey (#334155)
  /// Used for: Dark mode borders, dividers
  static const Color darkBorder = Color(0xFF334155);
  
  /// Dark Primary Green - Lighter for dark mode (#10b981)
  /// Used for: Primary elements in dark mode
  static const Color darkPrimaryGreen = Color(0xFF10b981);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  
  /// Donation Active - Bright green
  static const Color donationActive = Color(0xFF10b981);
  
  /// Donation Pending - Orange
  static const Color donationPending = Color(0xFFf59e0b);
  
  /// Donation Completed - Deep green
  static const Color donationCompleted = Color(0xFF059669);
  
  /// Donation Cancelled - Red
  static const Color donationCancelled = Color(0xFFef4444);
  
  /// NGO Verified - Green with checkmark feeling
  static const Color ngoVerified = Color(0xFF10b981);
  
  /// Impact Positive - Vibrant green
  static const Color impactPositive = Color(0xFF34d399);

  // ============================================
  // GRADIENT DEFINITIONS
  // ============================================
  
  /// Primary Gradient - Main brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF059669), // primaryGreen
      Color(0xFF10b981), // primaryGreenLight
    ],
  );
  
  /// Success Gradient - Positive action gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10b981), // success
      Color(0xFF34d399), // primaryGreenAccent
    ],
  );
  
  /// Subtle Gradient - Background gradient
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFffffff), // white
      Color(0xFFf8f9fa), // offWhite
    ],
  );
  
  /// Dark Gradient - Dark mode gradient
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0f172a), // darkBackground
      Color(0xFF1e293b), // darkSurface
    ],
  );

  // ============================================
  // SHADOW DEFINITIONS
  // ============================================
  
  /// Card Shadow - Subtle elevation
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Elevated Shadow - More prominent elevation
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Green Glow - Subtle green glow for emphasis
  static List<BoxShadow> get greenGlow => [
    BoxShadow(
      color: primaryGreen.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Get status color based on donation status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'created':
      case 'visible':
      case 'pending':
        return donationPending;
      case 'accepted':
      case 'intransit':
      case 'collected':
        return donationActive;
      case 'distributed':
      case 'completed':
        return donationCompleted;
      case 'cancelled':
      case 'expired':
        return donationCancelled;
      default:
        return textSecondary;
    }
  }
  
  /// Get impact color based on level (0-100)
  static Color getImpactColor(int level) {
    if (level >= 75) return primaryGreenAccent;
    if (level >= 50) return primaryGreen;
    if (level >= 25) return warning;
    return error;
  }
  
  /// Create color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
