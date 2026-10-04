import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/detail_page.dart';
import 'package:symptomm/widgets/common.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) => Shell(
        title: 'Specialty Library',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final specialty in specialties.values)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: card(),
                child: ListTile(
                  leading: Icon(specialty.icon, color: blue),
                  title: Text(specialty.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(specialty.brief),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(specialty)),
                  ),
                ),
              ),
          ],
        ),
      );
}
