import 'package:flutter/material.dart';
import 'package:symptomm/models/clinic_data.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/clinic_map_page.dart';
import 'package:symptomm/widgets/common.dart';

class DetailPage extends StatelessWidget {
  final Specialty specialty;

  const DetailPage(this.specialty, {super.key});

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
    final localClinics = searchClinics(specialty.name);

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
            onSubmitted: (value) {
              final query = value.trim();
              final matches = searchClinics(specialty.name, query: query);
              if (matches.isEmpty) {
                snack(context, 'No local clinics match that selection.');
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClinicMapPage(
                    clinics: matches,
                    title: '${specialty.name} clinics',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (localClinics.isNotEmpty)
            ...[
              const Text(
                'Nearby clinics',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              for (final clinic in localClinics.take(3))
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: card(),
                  child: ListTile(
                    title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${clinic.city} • ${clinic.address}'),
                    trailing: const Icon(Icons.location_on_outlined, color: blue),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClinicMapPage(
                          clinics: [clinic],
                          title: clinic.name,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          const SizedBox(height: 16),
          const Text(disclaimer, style: TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }
}
