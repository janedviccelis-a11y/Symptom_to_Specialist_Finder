import 'package:flutter/material.dart';
import 'package:symptomm/pages/results_page.dart';
import 'package:symptomm/services/history_service.dart';
import 'package:symptomm/widgets/common.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];
  bool loading = true;
  bool loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      loading = true;
      loadFailed = false;
    });
    try {
      final entries = await loadHistory();
      if (!mounted) return;
      setState(() {
        history = entries;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadFailed = true;
      });
    }
  }

  Future<void> _clearHistory() async {
    final previousHistory = history;
    setState(() => history = []);
    try {
      await clearHistory();
    } catch (_) {
      if (!mounted) return;
      setState(() => history = previousHistory);
      snack(context, 'Could not clear search history. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) => Shell(
        title: 'Search History',
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: history.isEmpty || loading ? null : _clearHistory,
          ),
        ],
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : loadFailed
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Could not load search history.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadHistory,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : history.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No searches yet. Start a symptom search and it will appear here.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final entry in history)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: card(radius: 20),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: insetSurface(radius: 14),
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: blue,
                                  ),
                                ),
                                title: Text(
                                  (entry['s'] as List).join(', '),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: Text(
                                  (entry['t'] as String)
                                      .substring(0, 16)
                                      .replaceFirst('T', '  '),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: mutedInk,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultsPage(
                                      List<String>.from(entry['s']),
                                      save: false,
                                    ),
                                  ),
                                ),
                                ),
                              ),
                            ),
                        ],
                      ),
      );
}
