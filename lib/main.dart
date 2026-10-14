import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'screens/edit_entry_screen.dart';
import 'screens/game_details_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const CartridgeApp());
}

class CartridgeApp extends StatelessWidget {
  const CartridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.home,
      routes: {
        // Tab routes all open MainScreen, each on its own tab.
        AppRoutes.home: (context) => const MainScreen(initialIndex: 0),
        AppRoutes.search: (context) => const MainScreen(initialIndex: 1),
        AppRoutes.stats: (context) => const MainScreen(initialIndex: 2),
        // Full-screen routes pushed on top of MainScreen.
        AppRoutes.gameDetails: (context) => const GameDetailsScreen(),
        AppRoutes.editEntry: (context) => const EditEntryScreen(),
      },
      
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }
}