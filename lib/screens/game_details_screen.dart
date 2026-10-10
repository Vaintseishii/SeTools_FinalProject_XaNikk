import 'package:flutter/material.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receives the RAWG game id passed from the Search screen.
    final gameId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(title: const Text('Game Details')),
      body: Center(child: Text('Game id: $gameId')),
    );
  }
}