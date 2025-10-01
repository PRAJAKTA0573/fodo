# 🎨 FODO Theme Guide - White & Green Design System

## Overview

FODO uses a sophisticated **White & Green** design system inspired by professional academic UI design (Minix), adapted specifically for a food donation platform. The theme conveys **sustainability, trust, and environmental consciousness** while maintaining excellent readability and modern aesthetics.

---

## 🌟 Design Philosophy

### Color Psychology
- **White Foundation**: Represents purity, cleanliness, and clarity
- **Green Primary**: Symbolizes growth, sustainability, environmental consciousness, and trust
- **Nature-Focused**: Aligns with the mission of reducing food waste and environmental impact

### Key Principles
1. **Readability First**: Dark text (#1f2937) on white backgrounds ensures optimal readability
2. **Minimal Distraction**: Clean white canvas reduces visual fatigue during extended use
3. **Professional Feel**: Business-appropriate while remaining warm and approachable
4. **Accessibility**: High contrast ratios meet WCAG guidelines
5. **Consistency**: Semantic naming and standardized spacing throughout

---

## 📐 Theme Structure

### File Organization
```
lib/core/theme/
├── app_colors.dart       # 40+ semantic colors, gradients, shadows
├── app_text_styles.dart  # 30+ typography styles
└── app_theme.dart        # Complete Material Design 3 configuration
```

---

## 🎨 Color Palette

### Primary Green Palette

| Color | Hex | Usage |
|-------|-----|-------|
| **Primary Green** | #059669 | Logo, primary buttons, navigation, key actions |
| **Primary Green Light** | #10b981 | Hover states, lighter accents, gradients |
| **Primary Green Dark** | #047857 | Active states, pressed buttons, emphasis |
| **Primary Green Lighter** | #d1fae5 | Backgrounds, subtle highlights, cards |
| **Primary Green Accent** | #34d399 | Success indicators, positive feedback |

### White Foundation

| Color | Hex | Usage |
|-------|-----|-------|
| **Pure White** | #ffffff | Cards, containers, modal backgrounds |
| **Off White** | #f8f9fa | Page backgrounds, section dividers |
| **Light Grey** | #f3f4f6 | Disabled states, borders, dividers |
| **Grey** | #e5e7eb | Inactive elements, secondary borders |

### Typography Colors

| Color | Hex | Usage |
|-------|-----|-------|
| **Text Primary** | #1f2937 | Main content, headers, important text |
| **Text Secondary** | #6b7280 | Secondary text, descriptions, captions |
| **Text Tertiary** | #9ca3af | Placeholders, disabled text, hints |
| **Text On Primary** | #ffffff | Text on green backgrounds |

### Accent Colors

| Color | Hex | Usage |
|-------|-----|-------|
| **Success** | #10b981 | Success messages, completed states |
| **Warning** | #f59e0b | Warnings, pending states, alerts |
| **Error** | #ef4444 | Errors, validation issues, critical alerts |
| **Info** | #3b82f6 | Info messages, tips, secondary actions |
| **Purple** | #7c3aed | Premium features, special badges |

### Semantic Colors

| Color | Hex | Usage |
|-------|-----|-------|
| **Donation Active** | #10b981 | Active donation status |
| **Donation Pending** | #f59e0b | Pending donation status |
| **Donation Completed** | #059669 | Completed donation status |
| **Donation Cancelled** | #ef4444 | Cancelled donation status |
| **NGO Verified** | #10b981 | Verified NGO badge |
| **Impact Positive** | #34d399 | Positive impact indicators |

---

## ✍️ Typography System

### Display Styles (Largest)
- **Display Large**: 40px, Bold - Hero text, splash screens
- **Display Medium**: 32px, Bold - Large headers, landing pages
- **Display Small**: 28px, Bold - Section headers

### Headline Styles
- **Headline Large**: 24px, Bold - Page titles
- **Headline Medium**: 20px, SemiBold - Card titles
- **Headline Small**: 18px, SemiBold - Subsection titles

### Title Styles
- **Title Large**: 22px, SemiBold - Dialog titles
- **Title Medium**: 16px, SemiBold - List item titles
- **Title Small**: 14px, SemiBold - Small titles

### Body Styles
- **Body Large**: 16px, Regular - Emphasized body text
- **Body Medium**: 14px, Regular - Regular body text
- **Body Small**: 12px, Regular - Small body text

### Label Styles
- **Label Large**: 14px, SemiBold - Button text, form labels
- **Label Medium**: 12px, SemiBold - Small button text
- **Label Small**: 11px, Medium - Tiny labels

### Specialized Styles
- **Button Text**: 16px, SemiBold - Primary button text
- **Caption**: 12px, Regular - Image captions, timestamps
- **Overline**: 10px, SemiBold - Labels, tags, uppercase
- **Number Large**: 48px, Bold - Statistics, large counts
- **Number Medium**: 32px, Bold - Counts, metrics
- **Number Small**: 20px, SemiBold - Small counts

---

## 🎯 Usage Examples

### 1. Using Colors in Your Widgets

```dart
import 'package:fodo/core/theme/app_colors.dart';

// Basic usage
Container(
  color: AppColors.primaryGreen,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)

// Using gradients
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
)

// Using shadows
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    boxShadow: AppColors.cardShadow,
    borderRadius: BorderRadius.circular(16),
  ),
)

// Status colors
Container(
  color: AppColors.getStatusColor('completed'),
  child: Text('Completed'),
)

// Impact colors
Icon(
  Icons.eco,
  color: AppColors.getImpactColor(85), // 85% impact
)
```

### 2. Using Text Styles

```dart
import 'package:fodo/core/theme/app_text_styles.dart';

// Basic usage
Text(
  'Welcome to FODO',
  style: AppTextStyles.headlineLarge,
)

Text(
  'Your donations make a difference',
  style: AppTextStyles.bodyMedium,
)

// Modified styles
Text(
  'Urgent Pickup',
  style: AppTextStyles.titleMedium.copyWith(
    color: AppColors.warning,
  ),
)

// Using helper methods
Text(
  'Success!',
  style: AppTextStyles.toGreen(AppTextStyles.headlineMedium),
)

// Status-based styles
Text(
  'Active',
  style: AppTextStyles.getStatusTextStyle('active'),
)
```

### 3. Themed Buttons

```dart
// Primary button (automatically styled by theme)
ElevatedButton(
  onPressed: () {},
  child: Text('Donate Food'),
)

// Outlined button
OutlinedButton(
  onPressed: () {},
  child: Text('Learn More'),
)

// Text button
TextButton(
  onPressed: () {},
  child: Text('Cancel'),
)

// Custom button with gradient
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppColors.greenGlow,
  ),
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    child: Text('Special Action'),
  ),
)
```

### 4. Themed Cards

```dart
Card(
  // Automatically uses theme styling
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Donation #1234',
          style: AppTextStyles.titleMedium,
        ),
        SizedBox(height: 8),
        Text(
          '50 meals available',
          style: AppTextStyles.bodyMedium,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryGreenLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Active',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    ),
  ),
)
```

### 5. Input Fields

```dart
TextField(
  // Automatically uses theme styling
  decoration: InputDecoration(
    labelText: 'Food Description',
    hintText: 'Enter food details',
    prefixIcon: Icon(Icons.food_bank),
  ),
)

// Custom styled input
TextField(
  decoration: InputDecoration(
    labelText: 'Special Field',
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.primaryGreen,
        width: 2,
      ),
    ),
  ),
)
```

### 6. Status Badges

```dart
Widget buildStatusBadge(String status) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.getStatusColor(status).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.getStatusColor(status),
        width: 1,
      ),
    ),
    child: Text(
      status.toUpperCase(),
      style: AppTextStyles.getStatusTextStyle(status),
    ),
  );
}
```

### 7. Impact Dashboard

```dart
Widget buildImpactCard(String title, int value, String unit) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColors.elevatedShadow,
    ),
    child: Column(
      children: [
        Text(
          value.toString(),
          style: AppTextStyles.numberLarge,
        ),
        SizedBox(height: 8),
        Text(
          unit,
          style: AppTextStyles.bodySmall,
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.labelMedium,
        ),
      ],
    ),
  );
}
```

---

## 🌙 Dark Mode Support

The theme system includes complete dark mode support:

```dart
// Dark mode colors
AppColors.darkBackground    // #0f172a
AppColors.darkSurface       // #1e293b
AppColors.darkBorder        // #334155
AppColors.darkPrimaryGreen  // #10b981

// Using dark theme
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system, // Follows system setting
)
```

---

## 📱 Responsive Design

### Breakpoints
```dart
class ResponsiveHelper {
  static bool isMobile(BuildContext context) => 
    MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) => 
    MediaQuery.of(context).size.width >= 600 && 
    MediaQuery.of(context).size.width < 1200;
  
  static bool isDesktop(BuildContext context) => 
    MediaQuery.of(context).size.width >= 1200;
}
```

---

## ✅ Best Practices

### 1. Always Use Theme Colors
```dart
// ✅ GOOD
Container(color: AppColors.primaryGreen)

// ❌ BAD
Container(color: Colors.green)
```

### 2. Use Semantic Colors
```dart
// ✅ GOOD
Container(color: AppColors.donationCompleted)

// ❌ BAD
Container(color: Color(0xFF059669))
```

### 3. Use Text Styles
```dart
// ✅ GOOD
Text('Title', style: AppTextStyles.titleMedium)

// ❌ BAD
Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
```

### 4. Maintain Consistency
- Use 12px border radius for most elements
- Use 16px padding for cards and containers
- Use 8px spacing between related elements
- Use 16-24px spacing between sections

### 5. Accessibility
- Maintain color contrast ratios
- Use semantic HTML/Flutter widgets
- Provide text alternatives for icons
- Support both light and dark modes

---

## 🎨 Component Examples

### Action Cards
```dart
Widget buildActionCard({
  required IconData icon,
  required String title,
  required String description,
  required VoidCallback onTap,
}) {
  return Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Stats Card
```dart
Widget buildStatsCard({
  required String label,
  required String value,
  required IconData icon,
  Color? color,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppColors.cardShadow,
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primaryGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color ?? AppColors.primaryGreen,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.numberSmall,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

## 🚀 Next Steps

1. ✅ Theme system implemented
2. 🔄 Apply to authentication screens
3. 🔄 Apply to donor dashboard and features
4. 🔄 Apply to NGO dashboard and features
5. 🔄 Test across all screens
6. 🔄 Optimize for performance
7. 🔄 Document any custom components

---

## 📚 References

- **Material Design 3**: https://m3.material.io/
- **Flutter Theming**: https://docs.flutter.dev/cookbook/design/themes
- **Color Theory**: https://material.io/design/color/the-color-system.html
- **Typography**: https://material.io/design/typography/the-type-system.html

---

**Theme Version**: 1.0.0  
**Last Updated**: October 1, 2025  
**Status**: Production Ready ✅

---

*Built with 🌿 for FODO - Making every meal count!*
