import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> loadHistory() async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getStringList('history') ?? [])
      .map((entry) => jsonDecode(entry) as Map<String, dynamic>)
      .toList();
}

Future<void> saveHistory(List<String> symptoms) async {
  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList('history') ?? [];
  history.insert(0, jsonEncode({'t': DateTime.now().toIso8601String(), 's': symptoms}));
  await prefs.setStringList('history', history.take(30).toList());
}
