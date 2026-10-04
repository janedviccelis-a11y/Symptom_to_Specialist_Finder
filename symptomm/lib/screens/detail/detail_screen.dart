import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/widgets/common.dart';

class DetailScreen extends StatelessWidget {
  final Specialty specialty;

  const DetailScreen(this.specialty, {super.key});

  Widget heading(String title) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink),
        ),
      );

  Widget bulletList(List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Text('•  $item', style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final firstWord = specialty.name.split(' ').first;
    final controller = TextEditingController();

    return Shell(
      title: '${specialty.name} - Specialty Details',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [blue, teal]),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: Icon(specialty.icon, size: 56, color: const Color(0xFFD33B3B)),
              ),
            ),
          ),
          heading('What is a $firstWord specialist?'),
          Text(specialty.about, style: const TextStyle(fontSize: 16)),
          heading('What Conditions They Handle'),
          bulletList(specialty.conditions),
          heading('When to See One'),
          Text(specialty.when, style: const TextStyle(fontSize: 16)),
          heading('Common Diagnostic Tests'),
          bulletList(specialty.tests),
          heading('Search for Local $firstWord Specialists'),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search city or clinic...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => snack(context, 'Local clinic search is planned for a future version.'),
          ),
          const SizedBox(height: 16),
          const Text(disclaimer, style: TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }
}
