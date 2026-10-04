import 'package:flutter/material.dart';
import 'package:symptomm/pages/about_page.dart';
import 'package:symptomm/pages/history_page.dart';
import 'package:symptomm/pages/library_page.dart';
import 'package:symptomm/pages/symptom_page.dart';
import 'package:symptomm/widgets/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Shell(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'BSCPE-4\nProject Proposal',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: blue, width: 7),
                ),
                child: const Icon(Icons.explore, size: 56, color: teal),
              ),
              const SizedBox(height: 16),
              const Text(
                'Symptom to\nSpecialist Finder',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Find the Right Doctor, Right Away.',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const Text('Your guided path to the correct medical expert.'),
              const SizedBox(height: 22),
              GBtn('Start New Symptom Search', () => go(context, const SymptomPage())),
              const SizedBox(height: 26),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.accessibility_new, size: 110, color: blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$disclaimer\n\nConsult a General Practitioner first for personalized advice.\nSEEK IMMEDIATE MEDICAL CARE IN EMERGENCIES.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final item in const [
                ['Recent Searches', HistoryPage()],
                ['Specialty Library', LibraryPage()],
                ['About this App', AboutPage()],
              ])
                TextButton(
                  onPressed: () => go(context, item[1] as Widget),
                  child: Text(
                    item[0] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      color: blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}
