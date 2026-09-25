import 'package:flutter/material.dart';

/// Green for Initial Plant top bar: light green in light mode, dark green in dark mode
const Color pvzGreenLight = Color(0xFF4CAF50);
const Color pvzGreenDark = Color(0xFF2E7D32);
const Color _pvzGreenContainer = Color(0xFFC8E6C9);
const Color _pvzBluePrimary = Color(0xFF2196F3);

/// Orange accent for Custom Zombie Properties (matches Kotlin PvzOrangeLight/Dark)
const Color pvzOrangeLight = Color(0xFFE8A000);
const Color pvzOrangeDark = Color(0xFFD5925E);

/// Yellow for custom zombie action buttons (Edit, Make custom = primary; Switch = secondary)
/// Light theme: brighter yellow for filled buttons, lighter for outlined
const Color pvzYellowLight = Color(0xFFFDD835);
const Color pvzYellowDark = Color(0xFFF9A825);
const Color pvzYellowLightMuted = Color(0xFFFFF59D);
const Color pvzYellowDarkMuted = Color(0xFFFFB300);

/// Snackbar background: save failed (dark yellow / light yellow)
const Color snackbarFailedDark = Color(0xFFB38600);
const Color snackbarFailedLight = Color(0xFFFFF59D);

/// Warning bar: missing modules (different yellow for dark/light theme)
const Color warningBarDark = Color(0xFFFFEB3B);
const Color warningBarLight = Color(0xFF8D6E00);
const Color warningBarBackgroundLight = Color(0xFFFFF59D);
const Color warningBarBackgroundDark = Color(0xFF8D6E00);

/// Background for editor warning banners (e.g. missing modules).
Color editorWarningBannerBackground(Brightness brightness) {
  return brightness == Brightness.dark
      ? warningBarBackgroundDark
      : warningBarBackgroundLight;
}

/// Foreground (text/icon) for editor warning banners.
Color editorWarningBannerForeground(Brightness brightness) {
  return brightness == Brightness.dark ? warningBarDark : warningBarLight;
}

/// Standard icons for editor alert banners (keep warning vs error distinct).
const IconData editorWarningIcon = Icons.warning_amber_rounded;
const IconData editorErrorIcon = Icons.error;

/// Purple for Custom Zombie card in Wave Timeline (matches Kotlin PvzPurpleLight/Dark)
const Color pvzPurpleLight = Color(0xFF673AB7);
const Color pvzPurpleDark = Color(0xFF8F76BB);

/// Brown for Tunnel Defend, Zombie Rush (matches Kotlin PvzBrownLight/Dark)
const Color pvzBrownLight = Color(0xFF795548);
const Color pvzBrownDark = Color(0xFF6E5E57);

/// Pink for Gulliver tunnel module
const Color pvzPinkLight = Color(0xFFE91E63);
const Color pvzPinkDark = Color(0xFFAD1457);

/// Light orange for Max Sun module (matches Kotlin PvzLightOrangeLight/Dark)
const Color pvzLightOrangeLight = Color(0xFFFF9800);
const Color pvzLightOrangeDark = Color(0xFFFFC97A);

/// Cyan for Starting Plantfood module (matches Kotlin PvzCyanLight/Dark)
const Color pvzCyanLight = Color(0xFF009688);
const Color pvzCyanDark = Color(0xFF479891);

/// Light blue for Custom Fish card in Wave Timeline
const Color pvzFishLight = Color(0xFFB3E5FC);
const Color pvzFishDark = Color(0xFF4FC3F7);

/// Usage guide card: dark blue in dark mode, light blue in light mode
const Color usageGuideDarkBg = Color(0xFF1C4D7C);
const Color usageGuideLightBg = Color(0xFFB3E5FC);
const Color usageGuideLightOnBg = Color(0xFF01579B);

const Color _darkSurface = Color(0xFF1E1E1E);
const Color _darkSurfaceVariant = Color(0xFF2C2C2C);
const Color _darkOnSurface = Color(0xFFE0E0E0);
const Color _darkOnSurfaceVariant = Color(0xFFB0B0B0);

const Color _lightSurface = Colors.white;
const Color _lightSurfaceVariant = Color(0xFFE8E8E8);
const Color _lightOnSurface = Color(0xFF212121);
const Color _lightOnSurfaceVariant = Color(0xFF616161);

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: pvzGreenLight,
      onPrimary: Colors.white,
      primaryContainer: _pvzGreenContainer,
      onPrimaryContainer: pvzGreenDark,
      secondary: _pvzBluePrimary,
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceContainerHighest: _lightSurfaceVariant,
      onSurfaceVariant: _lightOnSurfaceVariant,
      error: Colors.red.shade700,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: pvzGreenLight,
      onPrimary: Colors.black87,
      primaryContainer: pvzGreenDark,
      onPrimaryContainer: Colors.white,
      secondary: _pvzBluePrimary,
      onSecondary: Colors.black87,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceContainerHighest: _darkSurfaceVariant,
      onSurfaceVariant: _darkOnSurfaceVariant,
      error: Colors.red.shade400,
      onError: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
