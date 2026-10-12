import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/results_page.dart';
import 'package:symptomm/widgets/common.dart';
import 'package:symptomm/widgets/interactive_body_map.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  final selected = <String>{};
  final controller = TextEditingController();
  String area = cats.keys.first;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleSymptom(Symptom symptom, bool? value) => setState(() {
        if (value ?? false) {
          selected.add(symptom.name);
        } else {
          selected.remove(symptom.name);
        }
      });

  Widget symptomTile(Symptom symptom) => CheckboxListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: teal,
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor:
              symptom.red ? const Color(0xFFFFE8E5) : const Color(0xFFEAF4F2),
          child: Icon(
            symptom.red
                ? Icons.priority_high_rounded
                : (cats[symptom.cat] ?? Icons.healing),
            size: 18,
            color: symptom.red ? const Color(0xFFB6382F) : teal,
          ),
        ),
        title: Text(
          symptom.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: symptom.red
            ? const Text(
                'Urgent symptom',
                style: TextStyle(color: Color(0xFFB6382F), fontSize: 12),
              )
            : null,
        value: selected.contains(symptom.name),
        onChanged: (value) => toggleSymptom(symptom, value),
      );

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim();
    final areaSymptoms = symptoms.where((symptom) => symptom.cat == area);
    final areaResults = query.isEmpty
        ? areaSymptoms.toList()
        : search(query).where((symptom) => symptom.cat == area).toList();

    return Shell(
      title: 'Describe Your Symptoms',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              decoration: insetSurface(),
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search symptoms',
                  prefixIcon: const Icon(Icons.search_rounded, color: blue),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            controller.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: canvas,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          color: Color(0xFF347E77),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'MEDIORA  /  SYMPTOM CHECK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Where does it hurt?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: ink,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a part of the body to explore related symptoms.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: mutedInk,
                  ),
                ),
                const SizedBox(height: 14),
                InteractiveBodyMap(
                  selectedArea: area,
                  onAreaSelected: (value) => setState(() => area = value),
                ),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: card(radius: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A9B8F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          area,
                          style: TextStyle(
                            color: ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${areaResults.length} symptoms',
                        style: TextStyle(
                          color: mutedInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Related symptoms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: ink,
                        ),
                      ),
                    ),
                    Text(
                      '${areaResults.length} available',
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Material(
                  color: canvas,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFD7E1EC)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: areaResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            query.isEmpty
                                ? 'No symptoms are available for this area.'
                                : 'No matching symptoms here. Try another search or choose a different area.',
                            style: TextStyle(
                              color: Color(0xFF60747D),
                              height: 1.4,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (var index = 0;
                                index < areaResults.length;
                                index++)
                              Column(
                                children: [
                                  symptomTile(areaResults[index]),
                                  if (index < areaResults.length - 1)
                                    Divider(
                                      height: 1,
                                      indent: 68,
                                      endIndent: 14,
                                      color: outlineTone,
                                    ),
                                ],
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: canvas,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: .28)
                      : const Color(0xFFC9D5E3),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 19,
                      color: selected.isEmpty ? Colors.black45 : teal,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${selected.length} selected',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (selected.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(selected.clear),
                        child: const Text('Clear'),
                      ),
                  ],
                ),
                if (selected.isNotEmpty)
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final name in selected)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text(
                                name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () =>
                                  setState(() => selected.remove(name)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                  ),
                GBtn(
                  'See specialist matches',
                  selected.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultsPage(selected.toList()),
                            ),
                          ),
                ),
                const SizedBox(height: 7),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 15,
                      color: Color(0xFF9D302B),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Severe symptoms? Seek emergency care now.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF9D302B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
