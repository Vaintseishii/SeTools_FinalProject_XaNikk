import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:setools_final_project_xanikk/models/backlog_entry.dart';
import 'package:setools_final_project_xanikk/models/game.dart';
import 'package:setools_final_project_xanikk/providers/backlog_provider.dart';
import 'package:setools_final_project_xanikk/screens/backlog_screen.dart';
import 'package:setools_final_project_xanikk/widgets/game_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Regression test for the RangeError when a filter hides some games.
  testWidgets('filtering shows only matching games without errors', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = BacklogProvider();
    await provider.add(const Game(id: 1, name: 'The Witcher 3', slug: 'w3'));
    await provider.add(const Game(id: 2, name: 'Hades', slug: 'hades'));
    await provider.update(2, status: BacklogStatus.completed);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: BacklogScreen()),
      ),
    );
    expect(find.byType(GameTile), findsNWidgets(2));

    provider.setFilter(BacklogStatus.completed);
    await tester.pump();
    expect(find.byType(GameTile), findsOneWidget);
    expect(find.text('Hades'), findsOneWidget);

    provider.setFilter(BacklogStatus.dropped);
    await tester.pump();
    expect(find.byType(GameTile), findsNothing);
    expect(find.text('No dropped games.'), findsOneWidget);
  });
}