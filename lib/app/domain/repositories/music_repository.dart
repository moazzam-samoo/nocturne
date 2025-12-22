import '../entities/track.dart';

abstract class MusicRepository {
  Future<List<Track>> getTrendingMusic();
  Future<List<Track>> getRegionalMusic(); // For "Indian/Hindi" requirement
  Future<List<Track>> searchMusic(String query);
}
