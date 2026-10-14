import 'package:flutter/material.dart';
import 'backlog_screen.dart';
import 'search_screen.dart';
import 'stats_screen.dart';

// Switching tabs only changes the index so nothing is pushed onto the stack
class MainScreen extends StatefulWidget {
  /// Which tab to show first: 0 = Backlog, 1 = Search, 2 = Stats.
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;

  static const _tabs = [BacklogScreen(), SearchScreen(), StatsScreen()];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Backlog'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}