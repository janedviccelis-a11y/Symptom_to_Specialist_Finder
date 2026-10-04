import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/results_page.dart';
import 'package:symptomm/widgets/common.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final selected = <String>{};
  final controller = TextEditingController();
  bool bodyTab = false;
  String area = cats.keys.first;

  Widget tile(Symptom symptom) => CheckboxListTile(
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(symptom.name, style: const TextStyle(fontSize: 16)),
        value: selected.contains(symptom.name),
        onChanged: (value) => setState(() {
          if (value ?? false) {
            selected.add(symptom.name);
          } else {
            selected.remove(symptom.name);
          }
        }),
      );

  Widget tab(String title, bool isBody) => Expanded(
        child: InkWell(
          onTap: () => setState(() => bodyTab = isBody),
          child: Container(
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bodyTab == isBody ? Colors.white : const Color(0xFFD7E4E6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim();
    final List<Widget> items;

    if (query.isNotEmpty) {
      final results = search(query);
      items = results.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No matching symptoms. Try another word, or browse the categories.',
                ),
              ),
            ]
          : results.map(tile).toList();
    } else if (!bodyTab) {
      items = [
        for (final key in cats.keys)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: card(),
            child: ExpansionTile(
              key: PageStorageKey(key),
              shape: const Border(),
              collapsedShape: const Border(),
              initiallyExpanded: symptoms.any((s) => s.cat == key && selected.contains(s.name)),
              title: Text(key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              children: [for (final symptom in symptoms.where((s) => s.cat == key)) tile(symptom)],
            ),
          ),
      ];
    } else {
      items = [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in cats.keys)
              ChoiceChip(
                avatar: Icon(cats[key], size: 18),
                label: Text(key),
                selected: area == key,
                onSelected: (_) => setState(() => area = key),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: card(),
          child: Column(
            children: [for (final symptom in symptoms.where((s) => s.cat == area)) tile(symptom)],
          ),
        ),
      ];
    }

    return Shell(
      title: 'Describe Your Symptoms',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Type to search symptoms (e.g., persistent cough, skin rash)...',
                hintMaxLines: 2,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [tab('Symptoms', false), tab('Body Area Selector', true)],
            ),
          ),
          Expanded(child: ListView(padding: const EdgeInsets.all(16), children: items)),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  '${selected.length} Symptom${selected.length == 1 ? '' : 's'} Selected. Click to add more or:',
                ),
                const SizedBox(height: 8),
                GBtn(
                  'Continue to Results',
                  selected.isEmpty
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultsPage(selected.toList()),
                          ),
                        ),
                ),
                emergencyBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
