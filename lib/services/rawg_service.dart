import 'dart:convert';
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
    final results = body['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Game.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Game> getGameDetails(int id) async {
    final uri = Uri.parse('$_baseUrl/games/$id')
        .replace(queryParameters: {'key': _apiKey});

    final body = await _get(uri);
    return Game.fromJson(body);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    if (_apiKey.isEmpty) {
      throw RawgException(
          'Missing API key. Run with --dart-define=RAWG_KEY=yourkey');
    }

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw RawgException('RAWG error (${response.statusCode})');
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } on RawgException {
      rethrow;
    } catch (_) {
      throw RawgException('Could not reach RAWG. Check your connection.');
    }
  }
}