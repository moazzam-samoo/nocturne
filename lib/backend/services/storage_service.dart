import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/track_model.dart';
import '../domain/entities/track.dart';

class StorageService extends GetxService {
  late GetStorage _box;
  final RxList<Track> favoriteTracks = <Track>[].obs;
  final RxList<Track> downloadedTracks = <Track>[].obs;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    _loadFavorites();
    _loadDownloads();
    return this;
  }

  // --- Favorites ---

  void _loadFavorites() {
    final List<dynamic>? stored = _box.read<List<dynamic>>('favorites');
    if (stored != null) {
      favoriteTracks.value = stored.map((e) => TrackModel.fromJson(e)).toList();
    }
  }

  void toggleFavorite(Track track) {
    if (isFavorite(track)) {
      favoriteTracks.removeWhere((t) => t.id == track.id);
    } else {
      favoriteTracks.add(track);
    }
    _saveFavorites();
  }

  bool isFavorite(Track track) {
    return favoriteTracks.any((t) => t.id == track.id);
  }

  void _saveFavorites() {
    // Convert Track entities back to JSON-compatible maps (using TrackModel helper if possible or manual)
    // We cast to TrackModel to use toJson. If it's pure Track entity, we might need a mapper.
    // Assuming runtime objects are TrackModels.
    final list = favoriteTracks.map((t) {
      if (t is TrackModel) return t.toJson();
      return TrackModel(
        id: t.id, 
        name: t.name, 
        artistName: t.artistName, 
        albumImage: t.albumImage, 
        audioUrl: t.audioUrl, 
        duration: t.duration,
        album: t.album,
        year: t.year,
        genre: t.genre,
        releaseDate: t.releaseDate,
        popularity: t.popularity,
        hasLyrics: t.hasLyrics
      ).toJson();
    }).toList();
    _box.write('favorites', list);
  }

  // --- Downloads ---

  void _loadDownloads() {
    final List<dynamic>? stored = _box.read<List<dynamic>>('downloads');
    if (stored != null) {
      downloadedTracks.value = stored.map((e) => TrackModel.fromJson(e)).toList();
    }
  }

  void addDownload(Track track) {
    // Avoid duplicates
    if (!downloadedTracks.any((t) => t.id == track.id)) {
      downloadedTracks.add(track);
      _saveDownloads();
    }
  }

  void removeDownload(String id) {
    downloadedTracks.removeWhere((t) => t.id == id);
    _saveDownloads();
  }

  void _saveDownloads() {
    final list = downloadedTracks.map((t) {
       if (t is TrackModel) return t.toJson();
        return TrackModel(
        id: t.id, 
        name: t.name, 
        artistName: t.artistName, 
        albumImage: t.albumImage, 
        audioUrl: t.audioUrl, 
        duration: t.duration,
        album: t.album,
        year: t.year,
        genre: t.genre,
        releaseDate: t.releaseDate,
        popularity: t.popularity,
        hasLyrics: t.hasLyrics
      ).toJson();
    }).toList();
    _box.write('downloads', list);
  }
}
