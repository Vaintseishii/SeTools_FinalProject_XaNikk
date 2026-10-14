import 'package:flutter/material.dart';
import '../app_routes.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.gameDetails,
            arguments: 3328,
          ),
          child: const Text('Open Game Details (test)'),
        ),
      ),
    );
  }
}