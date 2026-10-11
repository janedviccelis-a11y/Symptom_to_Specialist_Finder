import 'package:flutter/material.dart';
import 'package:symptomm/pages/about_page.dart';
import 'package:symptomm/pages/history_page.dart';
import 'package:symptomm/pages/library_page.dart';
import 'package:symptomm/pages/symptom_page.dart';
import 'package:symptomm/widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Shell(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2F6AA3), Color(0xFF3E9A92)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x222F6AA3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Symptom to\nSpecialist Finder',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Understand which kind of care may be relevant to the symptoms you select.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: .92),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => go(context, const SymptomPage()),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Start New Symptom Search'),
                        style: FilledButton.styleFrom(
                          foregroundColor: blue,
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: card(),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This tool offers general specialty guidance, not a diagnosis. For severe or rapidly worsening symptoms, seek emergency care now.',
                        style: TextStyle(height: 1.4, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Explore',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in [
                (
                  'Recent searches',
                  'Review your saved symptom selections',
                  Icons.history_rounded,
                  const HistoryPage(),
                ),
                (
                  'Specialty library',
                  'Browse the available medical specialties',
                  Icons.medical_services_outlined,
                  const LibraryPage(),
                ),
                (
                  'About this app',
                  'Learn about the guidance and data sources',
                  Icons.info_outline_rounded,
                  const AboutPage(),
                ),
              ])
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white.withValues(alpha: .92),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFB9D7DC)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F2F1),
                      foregroundColor: blue,
                      child: Icon(item.$3),
                    ),
                    title: Text(
                      item.$1,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(item.$2),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => go(context, item.$4),
                  ),
                ),
            ],
          ),
        ),
      );
}
