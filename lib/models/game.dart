class Game {
  final int id;
  final String name;
  final String slug;
  final String? released;
  final String? backgroundImage;
  final double rating;
  final int? metacritic;
  final List<String> platforms;
  final List<String> genres;
  final String? description;

  const Game({
    required this.id,
    required this.name,
    required this.slug,
    this.released,
    this.backgroundImage,
    this.rating = 0.0,
    this.metacritic,
    this.platforms = const [],
    this.genres = const [],
    this.description,
  });

  /// Works for both the search list items and the detail response.
  /// `description_raw` only exists on the detail response.
  factory Game.fromJson(Map<String, dynamic> json) {
    final rawPlatforms = json['platforms'] as List<dynamic>? ?? [];
    final rawGenres = json['genres'] as List<dynamic>? ?? [];

    return Game(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      slug: json['slug'] as String? ?? '',
      released: json['released'] as String?,
      backgroundImage: json['background_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      metacritic: json['metacritic'] as int?,
      platforms: rawPlatforms
          .map((p) => (p as Map<String, dynamic>)['platform']?['name'])
          .whereType<String>()
          .toList(),
      genres: rawGenres
          .map((g) => (g as Map<String, dynamic>)['name'])
          .whereType<String>()
          .toList(),
      description: json['description_raw'] as String?,
    );
  }
}
