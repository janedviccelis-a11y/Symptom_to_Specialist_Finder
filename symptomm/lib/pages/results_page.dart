import 'package:flutter/material.dart';
import 'package:symptomm/models/symptom_data.dart';
import 'package:symptomm/pages/detail_page.dart';
import 'package:symptomm/pages/history_page.dart';
import 'package:symptomm/services/history_service.dart';
import 'package:symptomm/widgets/common.dart';

class ResultsPage extends StatefulWidget {
  final List<String> picked;
  final bool save;

  const ResultsPage(this.picked, {super.key, this.save = true});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late final Outcome out = analyze(widget.picked);
  bool az = false;
  int min = 0;

  @override
  void initState() {
    super.initState();
    if (widget.save) {
      saveHistory(widget.picked);
    }
  }

  Widget menu(String label, List<String> options, void Function(int) pick) =>
      PopupMenuButton<int>(
        onSelected: (value) => setState(() => pick(value)),
        itemBuilder: (_) => [
          for (var i = 0; i < options.length; i++)
            PopupMenuItem(value: i, child: Text(options[i])),
        ],
        child: Row(
          children: [
            Text(label,
                style:
                    const TextStyle(color: blue, fontWeight: FontWeight.w600)),
            const Icon(Icons.keyboard_arrow_down, color: blue),
          ],
        ),
      );

  Widget specialtyCard(BuildContext context, Rec recommendation, bool top) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: card(border: top ? teal : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2F1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(recommendation.s.icon, color: teal, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.s.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      if (top)
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            'TOP MATCH',
                            style: TextStyle(
                              color: Color(0xFF28745F),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recommendation.pct}% match',
                    style: const TextStyle(
                      color: Color(0xFF28734A),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: recommendation.pct / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFFE6ECEB),
                color: top ? teal : blue,
                semanticsLabel: 'Match strength',
                semanticsValue: '${recommendation.pct}',
              ),
            ),
            const SizedBox(height: 11),
            Text(
              recommendation.s.brief,
              style: const TextStyle(color: Color(0xFF42535D), height: 1.35),
            ),
            if (recommendation.because.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final symptom in recommendation.because.take(2))
                    Chip(
                      label: Text(symptom),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xFFF0F5F5),
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        color: ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (recommendation.because.length > 2)
                    Chip(
                      label: Text('+${recommendation.because.length - 2}'),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xFFF0F5F5),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: blue,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DetailPage(recommendation.s)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View details & clinics'),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final recommendations = out.recs.where((item) => item.pct >= min).toList();
    if (az) {
      recommendations.sort((a, b) => a.s.name.compareTo(b.s.name));
    }

    final urgent = out.flags.isNotEmpty;

    return Shell(
      actions: [
        menu('Filter', ['All matches', '50% and up', '70% and up'],
            (index) => min = [0, 50, 70][index]),
        const SizedBox(width: 12),
        menu('Sort', ['Best match', 'A to Z'], (index) => az = index == 1),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your matches',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: ink),
                ),
              ),
              IconButton(
                tooltip: 'Search history',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
                icon: const Icon(Icons.history),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: blue,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Based on ${widget.picked.length} selected symptom${widget.picked.length == 1 ? '' : 's'}',
              style: const TextStyle(color: Color(0xFF53636B)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: urgent ? const Color(0xFFFFE9E6) : const Color(0xFFE8F4EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  urgent ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: urgent
                      ? const Color(0xFFD33B3B)
                      : const Color(0xFF2E9A5B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    urgent
                        ? 'Urgent: ${out.flags.join(', ')}. Call emergency services now.'
                        : 'No urgent flags in your selection',
                    style: const TextStyle(height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (recommendations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No specialties match this filter. Choose "All matches" to see everything.',
              ),
            ),
          for (var i = 0; i < recommendations.length; i++)
            specialtyCard(
                context, recommendations[i], i == 0 && !az && min == 0),
          const SizedBox(height: 8),
          const Text(disclaimer, style: TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }
}
