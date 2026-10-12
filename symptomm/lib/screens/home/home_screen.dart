import 'package:flutter/material.dart';
import 'package:symptomm/app_state.dart';
import 'package:symptomm/pages/about_page.dart';
import 'package:symptomm/pages/symptom_page.dart';
import 'package:symptomm/widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: darkMode,
        builder: (context, _, __) => Shell(
          floatingActionButton: FloatingActionButton(
            tooltip: 'About Mediora',
            onPressed: () => go(context, const AboutPage()),
            backgroundColor: panel,
            foregroundColor: blue,
            elevation: 2,
            shape: const CircleBorder(),
            child: const Icon(Icons.info_outline_rounded),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: card(radius: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            'assets/images/mediora_logo.png',
                            fit: BoxFit.contain,
                            semanticLabel:
                                'Mediora medical cross and stethoscope',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEDIORA',
                            style: TextStyle(
                              color: ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'HEALTH GUIDANCE',
                            style: TextStyle(
                              color: mutedInk,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: isDarkMode
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        onPressed: () => setDarkMode(!isDarkMode),
                        style: IconButton.styleFrom(
                          foregroundColor: teal,
                          backgroundColor: panel,
                          minimumSize: const Size(44, 44),
                        ),
                        icon: Icon(
                          isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  decoration: card(radius: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: insetSurface(radius: 18),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: teal,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Your next step\nto better care.',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.06,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Understand which kind of specialist may be right for the symptoms you are experiencing.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: mutedInk,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => go(context, const SymptomPage()),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Start New Symptom Search'),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: teal,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: card(radius: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.health_and_safety_outlined,
                        color: teal,
                        size: 26,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          'Guidance, not a diagnosis. If symptoms are severe or rapidly worsening, seek emergency care.',
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 13,
                            color: ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
