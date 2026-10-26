import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/backlog_entry.dart';
import '../models/game.dart';

class BacklogProvider extends ChangeNotifier {
  static const String _storageKey = 'backlog_entries';

  final List<BacklogEntry> _entries = [];
  BacklogStatus? _filter; // null means "All"

  List<BacklogEntry> get entries => List.unmodifiable(_entries);
  BacklogStatus? get filter => _filter;

  /// Entries shown on the Backlog screen, based on the selected filter.
  List<BacklogEntry> get filteredEntries => _filter == null
      ? entries
      : _entries.where((e) => e.status == _filter).toList();

  // ---- Stats (used by the Stats screen) ----
  int get total => _entries.length;
  int countFor(BacklogStatus status) =>
      _entries.where((e) => e.status == status).length;
  double get completionRate =>
      total == 0 ? 0 : countFor(BacklogStatus.completed) / total;

  bool contains(int gameId) => _entries.any((e) => e.id == gameId);

  void setFilter(BacklogStatus? status) {
    _filter = status;
    notifyListeners();
  }

  // ---- Create ----
  Future<void> add(Game game) async {
    if (contains(game.id)) return;
    _entries.add(BacklogEntry.fromGame(game));
    notifyListeners();
    await _save();
  }

  // ---- Update ----
  Future<void> update(
    int gameId, {
    BacklogStatus? status,
    String? notes,
  }) async {
    final index = _entries.indexWhere((e) => e.id == gameId);
    if (index == -1) return;
    _entries[index] = _entries[index].copyWith(status: status, notes: notes);
    notifyListeners();
    await _save();
  }

  // ---- Delete ----
  Future<void> remove(int gameId) async {
    _entries.removeWhere((e) => e.id == gameId);
    notifyListeners();
    await _save();
  }

  // ---- Storage: the only two methods that touch shared_preferences ----

  /// Loads saved entries. Broken data never crashes the app:
  /// unreadable JSON gives an empty backlog, and bad entries are skipped.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final decoded = json.decode(raw);
      if (decoded is! List) return;

      final loaded = <BacklogEntry>[];
      for (final item in decoded) {
        try {
          final entry = BacklogEntry.fromJson(item as Map<String, dynamic>);
          // Skip duplicates so one game never shows up twice.
          if (!loaded.any((e) => e.id == entry.id)) loaded.add(entry);
        } catch (e) {
          debugPrint('Skipped a broken backlog entry: $e');
        }
      }

      _entries
        ..clear()
        ..addAll(loaded);
      notifyListeners();
    } catch (e) {
      debugPrint('Could not load backlog: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint('Could not save backlog: $e');
    }
  }
}
