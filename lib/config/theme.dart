import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color.dart';
import 'shapes.dart';
import 'spacing.dart';
import 'text_styles.dart';
import '../core/theme/component_themes.dart';

/// Travelindo Theme Configuration
/// Implements "Trust & Adventure" design system
class AppTheme {
  /// Light Theme Data
  static ThemeData get lightTheme {
    final scheme = ColorScheme.light(
      primary: AppColors.navy,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.navyAlt,
      onPrimaryContainer: AppColors.surface,
      secondary: AppColors.orange,
      onSecondary: AppColors.surface,
      secondaryContainer: AppColors.orange.withValues(alpha: 0.1),
      onSecondaryContainer: AppColors.orange,
      tertiary: AppColors.teal,
      onTertiary: AppColors.surface,
      tertiaryContainer: AppColors.teal.withValues(alpha: 0.1),
      onTertiaryContainer: AppColors.teal,
      error: AppColors.critical,
      onError: AppColors.surface,
      errorContainer: AppColors.critical.withValues(alpha: 0.1),
      onErrorContainer: AppColors.critical,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.lightGray,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: InkRipple.splashFactory,

      colorScheme: scheme,

      // ====== Page Transitions ======
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ====== Typography / Text Styles ======
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ====== App Bar Theme ======
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.surface),
        iconTheme: const IconThemeData(color: AppColors.surface),
      ),

      // ====== Floating Action Button Theme ======
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.surface,
        elevation: 4,
        extendedTextStyle: AppTextStyles.buttonPrimary,
      ),

      // ====== Button Themes ======
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppComponentThemes.primaryButton(),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppComponentThemes.secondaryButton(),
      ),

      textButtonTheme: TextButtonThemeData(
        style: AppComponentThemes.ghostButton(),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: AppComponentThemes.iconButtonFilled(),
      ),

      // ====== Input Field Theme ======
      inputDecorationTheme: AppComponentThemes.inputTheme(),

      // ====== Card Theme ======
      cardTheme: AppComponentThemes.travelCardTheme(),

      // ====== Bottom Navigation Theme (legacy M2) ======
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navy,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.surface.withValues(alpha: 0.7),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.navLabel.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.navLabel,
      ),

      // ====== Navigation Bar Theme (Material 3) ======
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navy,
        indicatorColor: AppColors.orange.withValues(alpha: 0.22),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.navLabel.copyWith(
            color: selected ? AppColors.orange : AppColors.surface.withValues(alpha: 0.72),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.orange : AppColors.surface.withValues(alpha: 0.72),
            size: 22,
          );
        }),
      ),

      // ====== Dialog Theme ======
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.lg,
        ),
        titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),

      // ====== Progress Indicator Theme ======
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.orange,
        circularTrackColor: AppColors.lightGray,
      ),

      // ====== Chip Theme ======
      chipTheme: AppComponentThemes.chipTheme(scheme),

      // ====== Divider Theme ======
      dividerTheme: DividerThemeData(
        color: AppColors.borderColor,
        thickness: 1,
        space: 12.h,
      ),

      // ====== Snackbar Theme ======
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.sm,
        ),
        elevation: 4,
      ),

      // ====== General Settings ======
      scaffoldBackgroundColor: AppColors.backgroundMain,
      canvasColor: AppColors.surface,
      disabledColor: AppColors.statusUnavailable,
      shadowColor: AppColors.shadow,
    );
  }

  /// Dark Theme Data
  static ThemeData get darkTheme {
    const surface = Color(0xFF1B263B);
    const background = Color(0xFF0D1B2A);
    const outline = Color(0xFF778DA9);

    final scheme = ColorScheme.dark(
      primary: const Color(0xFF90CAF9),
      onPrimary: background,
      primaryContainer: const Color(0xFF1E3A5F),
      onPrimaryContainer: AppColors.onDark,
      secondary: AppColors.orange,
      onSecondary: AppColors.onDark,
      secondaryContainer: const Color(0x33FF6B35),
      onSecondaryContainer: AppColors.orange,
      tertiary: AppColors.teal,
      onTertiary: AppColors.onDark,
      error: AppColors.critical,
      onError: AppColors.onDark,
      surface: surface,
      onSurface: AppColors.onDark,
      onSurfaceVariant: AppColors.onDarkMuted,
      outline: outline,
      surfaceContainerHighest: const Color(0xFF415A77),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      splashFactory: InkRipple.splashFactory,

      colorScheme: scheme,

      textTheme: _darkTextTheme(),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: AppColors.onDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.onDark),
        iconTheme: const IconThemeData(color: AppColors.onDark),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.onDark,
          shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF90CAF9)),
      ),

      inputDecorationTheme: AppComponentThemes.inputTheme().copyWith(
        fillColor: surface,
        hintStyle: AppTextStyles.placeholder.copyWith(color: AppColors.onDarkDimmed),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.md,
          side: const BorderSide(color: Color(0xFF415A77), width: 0.5),
        ),
      ),

      chipTheme: AppComponentThemes.chipTheme(scheme),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.onDarkMuted,
        textColor: AppColors.onDark,
        titleTextStyle: AppTextStyles.titleSmall.copyWith(color: AppColors.onDark),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onDarkMuted),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: AppColors.orange.withValues(alpha: 0.22),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.navLabel.copyWith(
            color: selected ? AppColors.orange : AppColors.onDarkDimmed,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.orange : AppColors.onDarkDimmed,
            size: 22,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.onDarkDimmed,
        type: BottomNavigationBarType.fixed,
      ),

      dividerTheme: DividerThemeData(
        color: const Color(0xFF415A77),
        thickness: 1,
        space: 12.h,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppShapes.lg),
        titleTextStyle: AppTextStyles.headlineLarge.copyWith(color: AppColors.onDark),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted),
      ),

      scaffoldBackgroundColor: background,
      canvasColor: surface,
    );
  }

  static TextTheme _darkTextTheme() {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.onDark),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.onDark),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.onDark),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.onDark),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.onDark),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.onDark),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.onDark),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.onDark),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.onDark),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.onDarkMuted),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.onDarkMuted),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.onDarkDimmed),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF90CAF9)),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.onDarkMuted),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.onDarkDimmed),
    );
  }

  // ====== Helper Method ======
  /// Get disabled text style
  static TextStyle _getDisabledStyle(TextStyle style) {
    return style.copyWith(
      color: style.color?.withValues(alpha: 0.5) ?? AppColors.textSecondary.withValues(alpha: 0.5),
    );
  }
}
