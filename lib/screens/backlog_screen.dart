import 'package:flutter/material.dart';
import '../app_routes.dart';

class BacklogScreen extends StatelessWidget {
  const BacklogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backlog')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.editEntry,
            arguments: 3328,
          ),
          child: const Text('Open Edit Entry (test)'),
        ),
      ),
    );
  }
}