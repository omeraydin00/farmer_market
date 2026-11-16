import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Logodaki yeşil ve turuncu baz alındı
  static const Color produceGreen = Color(0xFF3A8D3F);

  static ThemeData light() => _build(_lightScheme());

  static ThemeData dark() => _build(_darkScheme());

  static ColorScheme _lightScheme() {
    return ColorScheme.fromSeed(seedColor: produceGreen).copyWith(
      primary: const Color(0xFF2F7A34),
      // Sıcak, hafif krem tonlu yüzeyler
      surface: const Color(0xFFFAF7F0),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF5F1E8),
      surfaceContainer: const Color(0xFFF0EBE0),
      surfaceContainerHigh: const Color(0xFFEAE4D8),
      surfaceContainerHighest: const Color(0xFFE4DDCF),
      // Az kalan stok gibi uyarılar için turuncu
      tertiary: const Color(0xFF9A5B00),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFDDB6),
      onTertiaryContainer: const Color(0xFF311800),
    );
  }

  static ColorScheme _darkScheme() {
    return ColorScheme.fromSeed(seedColor: produceGreen, brightness: Brightness.dark).copyWith(
      surface: const Color(0xFF121511),
      surfaceContainerLowest: const Color(0xFF0D100C),
      surfaceContainerLow: const Color(0xFF1A1D18),
      surfaceContainer: const Color(0xFF1E221C),
      surfaceContainerHigh: const Color(0xFF282C26),
      surfaceContainerHighest: const Color(0xFF333731),
      tertiary: const Color(0xFFFFB960),
      onTertiary: const Color(0xFF4A2800),
      tertiaryContainer: const Color(0xFF6A3E00),
      onTertiaryContainer: const Color(0xFFFFDDB6),
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: textTheme.labelLarge,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.6)),
    );
  }
}
