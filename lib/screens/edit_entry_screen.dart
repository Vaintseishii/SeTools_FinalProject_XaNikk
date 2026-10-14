import 'package:flutter/material.dart';

class EditEntryScreen extends StatelessWidget {
  const EditEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receives a game id for now. Change this to a BacklogEntry
    final gameId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: Center(child: Text('Editing game id: $gameId')),
    );
  }
}