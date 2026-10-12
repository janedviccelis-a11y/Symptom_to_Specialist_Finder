import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final textScale = ValueNotifier<double>(1.0);
final darkMode = ValueNotifier<bool>(false);

Future<void> restoreThemePreference() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    darkMode.value = preferences.getBool('dark_mode') ?? false;
  } catch (error, stackTrace) {
    debugPrint('Could not restore the theme preference: $error\n$stackTrace');
  }
}

Future<void> setDarkMode(bool enabled) async {
  darkMode.value = enabled;
  try {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dark_mode', enabled);
  } catch (error, stackTrace) {
    debugPrint('Could not save the theme preference: $error\n$stackTrace');
  }
}
