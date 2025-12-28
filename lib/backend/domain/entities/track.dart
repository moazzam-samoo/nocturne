class Track {
  final String id;
  final String name;
  final String artistName;
  final String albumImage;
  final String audioUrl;
  final int duration;
  
  // New Metadata Fields
  final String album;
  final String year;
  final String genre;
  final String releaseDate;
  final String popularity;
  final bool hasLyrics;

  Track({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumImage,
    required this.audioUrl,
    required this.duration,
    this.album = '',
    this.year = '',
    this.genre = '',
    this.releaseDate = '',
    this.popularity = '',
    this.hasLyrics = false,
    this.localPath,
  });

  final String? localPath;
}
