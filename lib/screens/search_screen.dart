import 'package:flutter/material.dart';
import '../app_routes.dart';
import '../models/game.dart';
import '../services/rawg_service.dart';

enum _SearchState { idle, loading, error, empty, results }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _service = RawgService();

  _SearchState _state = _SearchState.idle;
  List<Game> _results = [];
  String _errorMessage = '';
  String _lastQuery = '';

  @override 
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calls the RAWG service and updates the screen state.
  /// An empty search is not sent to the API.
  Future<void> _search(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _state = _SearchState.loading;
      _lastQuery = text;
    });

    try {
      final games = await _service.searchGames(text);
      if (!mounted) return;
      setState(() {
        _results = games;
        _state = games.isEmpty ? _SearchState.empty : _SearchState.results;
      });
    } on RawgException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _state = _SearchState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _state = _SearchState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartridge')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _SearchState.idle:
        return const Center(child: Text('Search for a game by title.'));

      case _SearchState.loading:
        return const Center(child: CircularProgressIndicator());

      case _SearchState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _search(_lastQuery),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case _SearchState.empty:
        return const Center(child: Text('No games found.'));

      case _SearchState.results:
        return ListView.builder(
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final game = _results[index];
            return _ResultTile(
              game: game,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.gameDetails,
                arguments: game.id,
              ),
            );
          },
        );
    }
  }
}

/// Temporary result row. Swap for Xanth's GameTile once it exists.
class _ResultTile extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const _ResultTile({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final year = game.released?.split('-').first;
    final platforms = game.platforms.take(3).join(', ');
    final details = [
      if (year != null && year.isNotEmpty) year,
      if (platforms.isNotEmpty) platforms,
    ].join(' · ');

    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 56,
          height: 56,
          child: game.backgroundImage == null
              ? const Icon(Icons.videogame_asset)
              : Image.network(
                  game.backgroundImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.videogame_asset),
                ),
        ),
      ),
      title: Text(game.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16),
          const SizedBox(width: 2),
          Text(game.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }
}