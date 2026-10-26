import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';
import '../app_theme.dart';
import '../models/backlog_entry.dart';
import '../providers/backlog_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds automatically whenever the backlog changes.
    final backlog = context.watch<BacklogProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Stats')),
      body: backlog.total == 0
          ? const _EmptyStats()
          : _StatsContent(backlog: backlog),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart, size: 48),
          const SizedBox(height: 12),
          const Text('Add games to see stats.'),
          const SizedBox(height: 12),
          // Opens MainScreen on the Search tab.
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.search),
            icon: const Icon(Icons.search),
            label: const Text('Search games'),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final BacklogProvider backlog;

  const _StatsContent({required this.backlog});

  @override
  Widget build(BuildContext context) {
    final playing = backlog.countFor(BacklogStatus.playing);
    final completed = backlog.countFor(BacklogStatus.completed);
    final dropped = backlog.countFor(BacklogStatus.dropped);
    final rate = backlog.completionRate;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 14,
                    backgroundColor: Colors.black12,
                    color: AppColors.completed,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(rate * 100).round()}%',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Text('Completion rate'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _StatCard(label: 'Playing', count: playing),
            _StatCard(label: 'Completed', count: completed),
            _StatCard(label: 'Dropped', count: dropped),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          '% Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _BreakdownBar(playing: playing, completed: completed, dropped: dropped),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;

  const _StatCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('$count', style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final int playing;
  final int completed;
  final int dropped;

  const _BreakdownBar({
    required this.playing,
    required this.completed,
    required this.dropped,
  });

  @override
  Widget build(BuildContext context) {
    final total = playing + completed + dropped;
    final segments = [
      (playing, AppColors.playing, 'Playing'),
      (completed, AppColors.completed, 'Completed'),
      (dropped, AppColors.dropped, 'Dropped'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                for (final s in segments)
                  if (s.$1 > 0)
                    Expanded(
                      flex: s.$1,
                      child: Container(
                        color: s.$2,
                        alignment: Alignment.center,
                        child: Text(
                          '${(s.$1 / total * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Playing · Completed · Dropped'),
      ],
    );
  }
}
