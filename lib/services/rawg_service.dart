import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class RawgException implements Exception {
  final String message;
  RawgException(this.message);

  @override
  String toString() => message;
}

class RawgService {
  static const String _baseUrl = 'https://api.rawg.io/api';
  static const String _apiKey = String.fromEnvironment('RAWG_KEY');

  final http.Client _client;

  RawgService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Game>> searchGames(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/games').replace(queryParameters: {
      'key': _apiKey,
      'search': query.trim(),
      'page_size': '20',
    });

    final body = await _get(uri);
    final results = body['results'];
    if (results is! List) return [];

    // One broken game should not break the whole search, so skip it.
    final games = <Game>[];
    for (final item in results) {
      try {
        games.add(Game.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skipped a broken search result: $e');
      }
    }
    return games;
  }

  Future<Game> getGameDetails(int id) async {
    final uri = Uri.parse('$_baseUrl/games/$id')
        .replace(queryParameters: {'key': _apiKey});

    final body = await _get(uri);
    try {
      return Game.fromJson(body);
    } catch (_) {
      throw RawgException('RAWG sent game data we could not read.');
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    if (_apiKey.isEmpty) {
      throw RawgException(
          'Missing API key. Run with --dart-define=RAWG_KEY=yourkey');
    }

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw RawgException('RAWG took too long to answer. Please try again.');
    } catch (_) {
      throw RawgException('Could not reach RAWG. Check your connection.');
    }

    if (response.statusCode != 200) {
      throw RawgException(_messageFor(response.statusCode));
    }

    try {
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return decoded;
    } catch (_) {
      throw RawgException('RAWG sent data we could not read.');
    }
  }

  /// Turns an HTTP status code into a message the user can understand.
  String _messageFor(int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
        return 'RAWG rejected the API key. Check your RAWG_KEY.';
      case 404:
        return 'That game could not be found on RAWG.';
      case 429:
        return 'Too many requests to RAWG. Wait a moment and try again.';
      default:
        if (statusCode >= 500) {
          return 'RAWG is having problems right now. Try again later.';
        }
        return 'Something went wrong with RAWG ($statusCode).';
    }
  }
}