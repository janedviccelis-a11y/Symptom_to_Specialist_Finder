import 'package:flutter/material.dart';
import 'package:symptomm/app_state.dart';
import 'package:symptomm/screens/home/home_screen.dart';
import 'package:symptomm/widgets/common.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    restoreThemePreference();
  }

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF182633) : const Color(0xFFEAF1F8);
    final surface = isDark ? const Color(0xFF223544) : Colors.white;
    final foreground =
        isDark ? const Color(0xFFEAF2F8) : const Color(0xFF23384E);
    final muted = isDark ? const Color(0xFFA7BBCB) : const Color(0xFF637B91);
    final outline = isDark ? const Color(0xFF3B5264) : const Color(0xFFDCE5EF);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        surface: surface,
        brightness: brightness,
      ).copyWith(
        primary: blue,
        secondary: teal,
        onSurface: foreground,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1C2D3B) : background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: teal, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: teal,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? const Color(0xFF69CDE2) : blue,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? teal
              : (isDark ? surface : Colors.white),
        ),
        side: BorderSide(
          color: isDark ? const Color(0xFF71899C) : const Color(0xFF9EB4C7),
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: teal,
        thumbColor: teal,
        inactiveTrackColor:
            isDark ? const Color(0xFF3B5264) : const Color(0xFFD2DDE9),
        overlayColor: const Color(0x2232ACCC),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF314758) : ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: darkMode,
        builder: (_, isDark, __) => ValueListenableBuilder<double>(
          valueListenable: textScale,
          builder: (_, scale, __) => MaterialApp(
            title: 'Mediora',
            debugShowCheckedModeBanner: false,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const HomeScreen(),
          ),
        ),
      );
}
