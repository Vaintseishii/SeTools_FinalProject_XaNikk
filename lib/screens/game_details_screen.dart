import 'package:flutter/material.dart';
import '../models/game.dart';
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
          // Placeholder: the real layout comes in step 3.
          return Center(child: Text(snapshot.data!.name));
        },
      ),
      bottomNavigationBar: const SafeArea(child: RawgAttribution()),
    );
  }
}