import 'package:flutter/material.dart';
import 'package:symptomm/app_state.dart';
import 'package:symptomm/screens/home/home_screen.dart';
import 'package:symptomm/widgets/common.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
        valueListenable: textScale,
        builder: (_, scale, __) => MaterialApp(
          title: 'Symptom to Specialist Finder',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: blue),
            scaffoldBackgroundColor: const Color(0xFFE8F5F6),
          ),
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const HomeScreen(),
        ),
      );
}
