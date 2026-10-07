import 'package:flutter/material.dart';
import 'package:daily_you/l10n/generated/app_localizations.dart';

enum InterfaceStyle {
  standard('default'),
  p3('p3'),
  p5('p5');

  const InterfaceStyle(this.key);
  final String key;

  static InterfaceStyle fromKey(String key) =>
      values.firstWhere((style) => style.key == key, orElse: () => standard);

  String label(AppLocalizations l10n) => switch (this) {
        standard => l10n.interfaceStyleDefault,
        p3 => l10n.interfaceStyleP3,
        p5 => l10n.interfaceStyleP5,
      };
}

ThemeData applyInterfaceStyle(ThemeData base, InterfaceStyle style) {
  if (style == InterfaceStyle.standard) return base;
  final isP3 = style == InterfaceStyle.p3;
  final dark = base.brightness == Brightness.dark;
  final accent = isP3 ? const Color(0xff007cbd) : const Color(0xffc51636);
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: base.brightness,
    primary: dark
        ? (isP3 ? const Color(0xff6edcff) : const Color(0xffffb3bc))
        : accent,
    onPrimary: dark ? const Color(0xff101521) : Colors.white,
    surface: dark
        ? (isP3 ? const Color(0xff071b32) : const Color(0xff171216))
        : (isP3 ? const Color(0xffedf8ff) : const Color(0xfffff5f5)),
  );
  final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(isP3 ? 18 : 4));
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w900,
          letterSpacing: 1),
    ),
    cardTheme: CardThemeData(shape: shape, color: scheme.surfaceContainerLow),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: shape,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary),
    filledButtonTheme:
        FilledButtonThemeData(style: FilledButton.styleFrom(shape: shape)),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: shape,
    ),
  );
}

/// Wall-clock periods for daily use; these are not game progression states.
String personaPeriod(DateTime time, AppLocalizations l10n) {
  final hour = time.hour;
  if (hour < 5 || hour >= 22) return l10n.personaLateNight;
  if (hour < 8) return l10n.personaEarlyMorning;
  if (hour < 12) return l10n.personaMorning;
  if (hour < 14) return l10n.personaNoon;
  if (hour < 18) return l10n.personaAfternoon;
  return l10n.personaEvening;
}
