import 'package:flutter_test/flutter_test.dart';
import 'package:setools_final_project_xanikk/models/backlog_entry.dart';
import 'package:setools_final_project_xanikk/models/game.dart';
import 'package:setools_final_project_xanikk/providers/backlog_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const witcher = Game(id: 1, name: 'The Witcher 3', slug: 'witcher-3');
  const hades = Game(id: 2, name: 'Hades', slug: 'hades');

  late BacklogProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    provider = BacklogProvider();
  });

  test('add puts a game in the backlog as Playing', () async {
    await provider.add(witcher);
    expect(provider.total, 1);
    expect(provider.entries.first.status, BacklogStatus.playing);
  });

  test('adding the same game twice does not duplicate it', () async {
    await provider.add(witcher);
    await provider.add(witcher);
    expect(provider.total, 1);
  });

  test('update changes status and notes', () async {
    await provider.add(witcher);
    await provider.update(1, status: BacklogStatus.completed, notes: 'Done');
    expect(provider.entries.first.status, BacklogStatus.completed);
    expect(provider.entries.first.notes, 'Done');
  });

  test('remove deletes the game', () async {
    await provider.add(witcher);
    await provider.remove(1);
    expect(provider.total, 0);
  });

  test('filter and completion rate work', () async {
    await provider.add(witcher);
    await provider.add(hades);
    await provider.update(1, status: BacklogStatus.completed);

    expect(provider.completionRate, 0.5);
    expect(provider.countFor(BacklogStatus.playing), 1);

    provider.setFilter(BacklogStatus.completed);
    expect(provider.filteredEntries.length, 1);
  });

  test('backlog is saved and loaded again', () async {
    await provider.add(witcher);
    await provider.update(1, notes: 'Stopped at chapter 3');

    final fresh = BacklogProvider();
    await fresh.load();

    expect(fresh.total, 1);
    expect(fresh.entries.first.notes, 'Stopped at chapter 3');
  });
}