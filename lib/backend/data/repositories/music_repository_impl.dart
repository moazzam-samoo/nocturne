import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../providers/saavn_provider.dart';

class MusicRepositoryImpl implements MusicRepository {
  final SaavnProvider provider;

  MusicRepositoryImpl({required this.provider});

  @override
  Future<List<Track>> getTracks({int limit = 10, String tags = ''}) async {
    // Saavn API uses generic search, so we treat 'tags' as a search query
    // e.g. "Bollywood", "Hollywood", "Pop"
    String query = tags.replaceAll('+', ' ');
    if (query.isEmpty) query = 'Trending';

    return await provider.searchTracks(query);
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    return await provider.searchTracks(query);
  }
}
