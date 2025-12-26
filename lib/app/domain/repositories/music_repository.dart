import '../entities/track.dart';

abstract class MusicRepository {
  Future<List<Track>> getTracks({int limit = 50, String tags});
  Future<List<Track>> searchTracks(String query);
}
