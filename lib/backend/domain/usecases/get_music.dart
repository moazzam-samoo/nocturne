import '../entities/track.dart';
import '../repositories/music_repository.dart';

class GetTrendingMusic {
  final MusicRepository repository;

  GetTrendingMusic(this.repository);

  Future<List<Track>> call() async {
    return await repository.getTrendingMusic();
  }
}

class GetRegionalMusic {
  final MusicRepository repository;

  GetRegionalMusic(this.repository);

  Future<List<Track>> call() async {
    return await repository.getRegionalMusic();
  }
}
