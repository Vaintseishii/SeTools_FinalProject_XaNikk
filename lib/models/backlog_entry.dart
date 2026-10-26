import 'game.dart';

enum BacklogStatus { playing, completed, dropped }

extension BacklogStatusLabel on BacklogStatus {
  String get label {
    switch (this) {
      case BacklogStatus.playing:
        return 'Playing';
      case BacklogStatus.completed:
        return 'Completed';
      case BacklogStatus.dropped:
        return 'Dropped';
    }
  }
}

/// One game saved in the user's backlog. It copies the game info it needs
/// so the Backlog screen works without internet.
class BacklogEntry {
  final int id;
  final String name;
  final String? backgroundImage;
  final List<String> platforms;
  final List<String> genres;
  final BacklogStatus status;
  final String notes;

  const BacklogEntry({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.platforms = const [],
    this.genres = const [],
    this.status = BacklogStatus.playing,
    this.notes = '',
  });

  /// Builds a new entry from a Game (used by "Add to backlog").
  factory BacklogEntry.fromGame(Game game) {
    return BacklogEntry(
      id: game.id,
      name: game.name,
      backgroundImage: game.backgroundImage,
      platforms: game.platforms,
      genres: game.genres,
    );
  }

  BacklogEntry copyWith({BacklogStatus? status, String? notes}) {
    return BacklogEntry(
      id: id,
      name: name,
      backgroundImage: backgroundImage,
      platforms: platforms,
      genres: genres,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'backgroundImage': backgroundImage,
    'platforms': platforms,
    'genres': genres,
    'status': status.name,
    'notes': notes,
  };

  factory BacklogEntry.fromJson(Map<String, dynamic> json) {
    return BacklogEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      backgroundImage: json['backgroundImage'] as String?,
      platforms: List<String>.from(json['platforms'] as List? ?? []),
      genres: List<String>.from(json['genres'] as List? ?? []),
      status: BacklogStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => BacklogStatus.playing,
      ),
      notes: json['notes'] as String? ?? '',
    );
  }
}
