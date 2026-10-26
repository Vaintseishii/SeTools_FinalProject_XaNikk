import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_routes.dart';
import '../models/game.dart';
import '../services/rawg_service.dart';
import '../widgets/game_tile.dart';

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

  /// Goes up by one on every search. A reply is only shown if it belongs
  /// to the newest search, so a slow old reply can't replace new results.
  int _searchId = 0;

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
    final id = ++_searchId;
    setState(() {
      _state = _SearchState.loading;
      _lastQuery = text;
    });

    try {
      final games = await _service.searchGames(text);
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = games;
        _state = games.isEmpty ? _SearchState.empty : _SearchState.results;
      });
    } on RawgException catch (e) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _errorMessage = e.message;
        _state = _SearchState.error;
      });
    } catch (_) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _state = _SearchState.error;
      });
    }
  }

  /// Clears the search and goes back to the starting message.
  void _clear() {
    _controller.clear();
    _searchId++; // ignore any search that is still loading
    setState(() {
      _results = [];
      _lastQuery = '';
      _state = _SearchState.idle;
    });
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
              onChanged: (value) {
                if (value.trim().isEmpty && _state != _SearchState.idle) {
                  _clear();
                } else {
                  setState(() {}); // show or hide the clear button
                }
              },
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear',
                        onPressed: _clear,
                      ),
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No games found for "$_lastQuery".',
              textAlign: TextAlign.center,
            ),
          ),
        );

      case _SearchState.results:
        return ListView.builder(
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final game = _results[index];
            final year = game.released?.split('-').first;
            final platforms = game.platforms.take(3).join(', ');
            return GameTile(
              title: game.name,
              imageUrl: game.backgroundImage,
              subtitle: [
                if (year != null && year.isNotEmpty) year,
                if (platforms.isNotEmpty) platforms,
              ].join(' · '),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16),
                  const SizedBox(width: 2),
                  Text(game.rating.toStringAsFixed(1)),
                ],
              ),
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
