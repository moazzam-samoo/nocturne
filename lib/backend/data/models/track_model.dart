import '../../domain/entities/track.dart';

class TrackModel extends Track {
  TrackModel({
    required String id,
    required String name,
    required String artistName,
    required String albumImage,
    required String audioUrl,
    required int duration,
    String album = '',
    String year = '',
    String genre = '',
    String releaseDate = '',
    String popularity = '',
    bool hasLyrics = false,
    String? localPath,
  }) : super(
          id: id,
          name: name,
          artistName: artistName,
          albumImage: albumImage,
          audioUrl: audioUrl,
          duration: duration,
          album: album,
          year: year,
          genre: genre,
          releaseDate: releaseDate,
          popularity: popularity,
          hasLyrics: hasLyrics,
          localPath: localPath,
        );

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      albumImage: json['image'] ?? '',
      audioUrl: json['audio'] ?? '',
      duration: json['duration'] ?? 0,
      album: json['album'] ?? '',
      year: json['year'] ?? '',
      genre: json['genre'] ?? '',
      releaseDate: json['release_date'] ?? '',
      popularity: json['popularity'] ?? '',
      hasLyrics: json['has_lyrics'] == true || json['has_lyrics'] == 'true',
      localPath: json['local_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'image': albumImage,
      'audio': audioUrl,
      'duration': duration,
      'album': album,
      'year': year,
      'genre': genre,
      'release_date': releaseDate,
      'popularity': popularity,
      'has_lyrics': hasLyrics,
      'local_path': localPath,
    };
  }
}
