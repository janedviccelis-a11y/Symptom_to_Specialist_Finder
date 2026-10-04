import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptomm/pages/results_page.dart';
import 'package:symptomm/services/history_service.dart';
import 'package:symptomm/widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> future = loadHistory();

  @override
  Widget build(BuildContext context) => Shell(
        title: 'Search History',
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              (await SharedPreferences.getInstance()).remove('history');
              setState(() => future = loadHistory());
            },
          ),
        ],
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data!;
            if (history.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No searches yet. Start a symptom search and it will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in history)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: card(),
                    child: ListTile(
                      title: Text(
                        (entry['s'] as List).join(', '),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text((entry['t'] as String).substring(0, 16).replaceFirst('T', '  ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsPage(List<String>.from(entry['s']), save: false),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}
