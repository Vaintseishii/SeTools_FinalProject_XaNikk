import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';
import '../models/game.dart';
import '../providers/backlog_provider.dart';
import '../services/rawg_service.dart';
import '../widgets/rawg_attribution.dart';

class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({super.key});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  final _service = RawgService();
  late int _gameId;
  Future<Game>? _gameFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch once, not on every rebuild.
    if (_gameFuture == null) {
      _gameId = ModalRoute.of(context)!.settings.arguments as int;
      _gameFuture = _service.getGameDetails(_gameId);
    }
  }

  void _retry() {
    setState(() => _gameFuture = _service.getGameDetails(_gameId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Details')),
      body: FutureBuilder<Game>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is RawgException
                ? error.message
                : 'Something went wrong. Please try again.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _GameDetailsBody(game: snapshot.data!);
        },
      ),
      bottomNavigationBar: const SafeArea(child: RawgAttribution()),
    );
  }
}

class _GameDetailsBody extends StatelessWidget {
  final Game game;

  const _GameDetailsBody({required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = game.released?.split('-').first;
    final description = game.description?.trim() ?? '';
    final inBacklog = context.watch<BacklogProvider>().contains(game.id);

    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: game.backgroundImage == null
              ? ColoredBox(
                  color: theme.colorScheme.secondary,
                  child: const Icon(Icons.videogame_asset,
                      size: 64, color: Colors.white),
                )
              : Image.network(
                  game.backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.videogame_asset, size: 64),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(game.rating.toStringAsFixed(1)),
                  if (game.metacritic != null) ...[
                    const SizedBox(width: 16),
                    Text('Metacritic ${game.metacritic}'),
                  ],
                  if (year != null && year.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Text(year),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: inBacklog
                    ? OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.editEntry,
                          arguments: game.id,
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit entry'),
                      )
                    : FilledButton.icon(
                        onPressed: () async {
                          await context.read<BacklogProvider>().add(game);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${game.name} added to backlog')),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add to backlog'),
                      ),
              ),
              _chipSection(theme, 'Genres', game.genres),
              _chipSection(theme, 'Platforms', game.platforms),
              const SizedBox(height: 16),
              Text('About', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description.isEmpty
                  ? 'No description available.'
                  : description),
            ],
          ),
        ),
      ],
    );
  }

  /// A title with one chip per item. Hidden when the list is empty.
  Widget _chipSection(ThemeData theme, String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) => Chip(label: Text(item))).toList(),
          ),
        ],
      ),
    );
  }
}