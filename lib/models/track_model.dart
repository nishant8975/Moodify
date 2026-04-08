class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String? coverUrl;
  final int durationSeconds;
  final String genre;

  TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    this.coverUrl,
    required this.durationSeconds,
    required this.genre,
  });

  factory TrackModel.fromMap(Map<String, dynamic> map) {
    return TrackModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Unknown',
      artist: map['artist'] ?? 'Unknown',
      audioUrl: map['audio_url'] ?? '',
      coverUrl: map['cover_url'],
      durationSeconds: map['duration_seconds'] ?? 0,
      genre: map['genre'] ?? 'Unknown',
    );
  }

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
