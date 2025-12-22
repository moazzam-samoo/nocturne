import '../entities/track.dart';
import '../repositories/music_repository.dart';

class SearchMusic {
  final MusicRepository repository;

  SearchMusic(this.repository);

  Future<List<Track>> call(String query) async {
    return await repository.searchMusic(query);
  }
}
