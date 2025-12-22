import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../providers/jamendo_provider.dart';

class MusicRepositoryImpl implements MusicRepository {
  final JamendoProvider provider;

  MusicRepositoryImpl({required this.provider});

  @override
  Future<List<Track>> getTrendingMusic() async {
    return await provider.getTrendingMusic();
  }

  @override
  Future<List<Track>> getRegionalMusic() async {
    return await provider.getRegionalMusic();
  }

  @override
  Future<List<Track>> searchMusic(String query) async {
    return await provider.searchMusic(query);
  }
}
