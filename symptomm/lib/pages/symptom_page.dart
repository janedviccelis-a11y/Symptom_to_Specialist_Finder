import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/results_page.dart';
import 'package:symptomm/widgets/common.dart';

class SymptomPage extends StatefulWidget {
  const SymptomPage({super.key});

  @override
  State<SymptomPage> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
  final selected = <String>{};
  final controller = TextEditingController();
  bool bodyTab = false;
  String area = cats.keys.first;

  static const categoryIcons = <String, IconData>{
    'Head & Neck': Icons.face_3_outlined,
    'Chest & Breathing': Icons.monitor_heart_outlined,
    'Abdomen & Digestion': Icons.medication_liquid_outlined,
    'Muscles & Joints': Icons.accessibility_new,
    'Skin & Hair': Icons.spa_outlined,
  };

  static const categoryColors = <String, Color>{
    'Head & Neck': Color(0xFF5579B8),
    'Chest & Breathing': Color(0xFFC45D51),
    'Abdomen & Digestion': Color(0xFFB17B35),
    'Muscles & Joints': Color(0xFF4D8B70),
    'Skin & Hair': Color(0xFF9A668E),
  };

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

    Widget tile(Symptom symptom) => Material(
      color: Colors.transparent,
      child: CheckboxListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        controlAffinity: ListTileControlAffinity.trailing,
        secondary: CircleAvatar(
          radius: 18,
          backgroundColor:
              symptom.red ? const Color(0xFFFFE8E5) : const Color(0xFFE4F2F0),
          child: Icon(
            symptom.red
                ? Icons.priority_high_rounded
                : (cats[symptom.cat] ?? Icons.healing),
            size: 19,
            color: symptom.red ? const Color(0xFFB6382F) : teal,
          ),
        ),
        title: Text(symptom.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: symptom.red ? const Text('Urgent symptom') : null,
        value: selected.contains(symptom.name),
          onChanged: (value) => toggleSymptom(symptom, value),
        ),
      );

  Widget categoryIllustration(String key,
          {double size = 30, double boxSize = 58}) =>
      Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: categoryColors[key]!.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(categoryIcons[key], size: size, color: categoryColors[key]),
      );

  int selectedCount(String key) =>
      symptoms.where((s) => s.cat == key && selected.contains(s.name)).length;

  Widget areaChoice(String key) {
    final isSelected = area == key;
    final count = selectedCount(key);
    return SizedBox(
      width: 154,
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => area = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: .58),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isSelected ? categoryColors[key]! : const Color(0xFFD7E4E6),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                categoryIllustration(key, size: 22, boxSize: 42),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(key,
                          maxLines: 3,
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700)),
                      if (count > 0)
                        Text('$count selected',
                            style: TextStyle(
                                fontSize: 11, color: categoryColors[key])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget categoryCard(String key) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: card(),
        child: ExpansionTile(
          key: PageStorageKey(key),
          shape: const Border(),
          collapsedShape: const Border(),
          initiallyExpanded:
              symptoms.any((s) => s.cat == key && selected.contains(s.name)),
          leading: categoryIllustration(key, size: 29),
          title: Text(key,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          subtitle: Text(
            selectedCount(key) > 0
                ? '${selectedCount(key)} selected'
                : '${symptoms.where((s) => s.cat == key).length} symptoms',
          ),
          children: [
            for (final symptom in symptoms.where((s) => s.cat == key))
              tile(symptom)
          ],
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
      items = [for (final key in cats.keys) categoryCard(key)];
    } else {
      items = [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final key in cats.keys) areaChoice(key)],
        ),
        const SizedBox(height: 14),
        Text(area,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 6),
        Container(
          decoration: card(),
          child: Column(
            children: [
              for (final symptom in symptoms.where((s) => s.cat == area))
                tile(symptom)
            ],
          ),
        ),
      ];
    }

    return Shell(
      title: 'Describe Your Symptoms',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search symptoms',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          controller.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: false,
                    icon: Icon(Icons.list_alt),
                    label: Text('Symptoms')),
                ButtonSegment(
                    value: true,
                    icon: Icon(Icons.accessibility_new),
                    label: Text('Body area')),
              ],
              selected: {bodyTab},
              onSelectionChanged: (value) =>
                  setState(() => bodyTab = value.first),
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .65),
                foregroundColor: ink,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: ink,
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                padding: const EdgeInsets.symmetric(vertical: 11),
                side: BorderSide.none,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              reverseDuration: const Duration(milliseconds: 160),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, .025),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: ListView(
                key: ValueKey('$bodyTab:$area:${controller.text.isNotEmpty}'),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                children: [
                  if (query.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        bodyTab
                            ? 'Choose a body area'
                            : 'Choose what you are feeling',
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: ink),
                      ),
                    ),
                  ...items,
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 19,
                        color: selected.isEmpty ? Colors.black45 : teal),
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
                              label: Text(name,
                                  style: const TextStyle(fontSize: 12)),
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
                    Icon(Icons.warning_amber_rounded,
                        size: 15, color: Color(0xFF9D302B)),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Severe symptoms? Seek emergency care now.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 11.5, color: Color(0xFF9D302B)),
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
