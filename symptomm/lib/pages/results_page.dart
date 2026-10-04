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

  Widget menu(String label, List<String> options, void Function(int) pick) => PopupMenuButton<int>(
        onSelected: (value) => setState(() => pick(value)),
        itemBuilder: (_) => [
          for (var i = 0; i < options.length; i++)
            PopupMenuItem(value: i, child: Text(options[i])),
        ],
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: blue, fontWeight: FontWeight.w600)),
            const Icon(Icons.keyboard_arrow_down, color: blue),
          ],
        ),
      );

  Widget specialtyCard(BuildContext context, int number, Rec recommendation, bool top) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: card(border: top ? teal : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('$number', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.s.name,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${recommendation.pct}% Match',
                  style: const TextStyle(
                    color: Color(0xFF2E9A5B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Based on: '),
                  TextSpan(
                    text: recommendation.because.join(', '),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Suggested because these symptoms are commonly handled by ${recommendation.s.name}. ${recommendation.s.brief}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(recommendation.s)),
                    ),
                    child: const Text('Learn More'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => snack(
                      context,
                      'Booking is not part of this prototype. Please contact a clinic directly.',
                    ),
                    child: const Text('Book Appointment'),
                  ),
                ),
              ],
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
        menu('Filter', ['All matches', '50% and up', '70% and up'], (index) => min = [0, 50, 70][index]),
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
                  'Your Specialty\nRecommendations',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1, color: ink),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryPage()),
                ),
                child: const Text('Search History'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: urgent ? const Color(0xFFFBDDDD) : const Color(0xFFD3EBDD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  urgent ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: urgent ? const Color(0xFFD33B3B) : const Color(0xFF2E9A5B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Urgent Assessment Check: ',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        TextSpan(
                          text: urgent ? 'ATTENTION\n' : 'OK\n',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        TextSpan(
                          text: urgent
                              ? 'Red-flag symptom(s): ${out.flags.join(', ')}. Seek immediate medical care or call emergency services.'
                              : 'No red-flag symptoms were found in your selection.',
                        ),
                      ],
                    ),
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
            specialtyCard(context, i + 1, recommendations[i], i == 0 && !az && min == 0),
          const SizedBox(height: 8),
          const Text(disclaimer, style: TextStyle(fontSize: 12.5)),
        ],
      ),
    );
  }
}
