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
  Future<void> update(int gameId, {BacklogStatus? status, String? notes}) async {
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
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    final list = json.decode(raw) as List<dynamic>;
    _entries
      ..clear()
      ..addAll(list.map((e) => BacklogEntry.fromJson(e as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}