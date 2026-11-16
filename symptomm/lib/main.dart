import 'package:flutter/material.dart';
import 'package:symptomm/app.dart';
import 'package:symptomm/services/auth_service.dart';

export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabaseIfConfigured();
  runApp(const MyApp());
}
