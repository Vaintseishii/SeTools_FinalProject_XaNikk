import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';
import '../models/backlog_entry.dart';
import '../models/game.dart';
import '../providers/backlog_provider.dart';
import '../widgets/game_tile.dart';
import '../widgets/status_chip.dart';

class BacklogScreen extends StatelessWidget {
  const BacklogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backlog = context.watch<BacklogProvider>();
    final entries = backlog.filteredEntries;

    return Scaffold(
      appBar: AppBar(title: const Text('Backlog')),
      body: Column(
        children: [
          _FilterBar(selected: backlog.filter, onSelected: backlog.setFilter),
          Expanded(
            child: backlog.total == 0
                ? const _EmptyBacklog()
                : ListView.builder(
                    itemCount: backlog.entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return GameTile(
                        title: entry.name,
                        imageUrl: entry.backgroundImage,
                        subtitle: entry.platforms.take(3).join(', '),
                        trailing: StatusChip(status: entry.status),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.editEntry,
                          arguments: entry.id,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// All / Playing / Completed / Dropped chips. null means "All".
class _FilterBar extends StatelessWidget {
  final BacklogStatus? selected;
  final ValueChanged<BacklogStatus?> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = <BacklogStatus?>[null, ...BacklogStatus.values];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final status in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status?.label ?? 'All'),
                selected: selected == status,
                onSelected: (_) => onSelected(status),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyBacklog extends StatelessWidget {
  const _EmptyBacklog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videogame_asset_outlined, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Your backlog is empty.\nSearch for a game to add it.',
            textAlign: TextAlign.center,
          ),
          // Debug-only helper until Game Details can add games. Remove in #12.
          if (kDebugMode)
            TextButton(
              onPressed: () => _addSampleGames(context.read<BacklogProvider>()),
              child: const Text('Add sample games (debug)'),
            ),
        ],
      ),
    );
  }

  Future<void> _addSampleGames(BacklogProvider backlog) async {
    await backlog.add(
      const Game(
        id: 3328,
        name: 'The Witcher 3: Wild Hunt',
        slug: 'the-witcher-3-wild-hunt',
        platforms: ['PC', 'PlayStation 4'],
      ),
    );
    await backlog.add(
      const Game(
        id: 274755,
        name: 'Hades',
        slug: 'hades-2',
        platforms: ['PC', 'Nintendo Switch'],
      ),
    );
    await backlog.add(
      const Game(
        id: 22511,
        name: 'The Legend of Zelda: Breath of the Wild',
        slug: 'the-legend-of-zelda-breath-of-the-wild',
        platforms: ['Nintendo Switch'],
      ),
    );
    await backlog.update(274755, status: BacklogStatus.completed);
  }
}