import 'package:get/get.dart';
import '../../domain/entities/track.dart';
import '../../services/storage_service.dart';

class FavoritesController extends GetxController {
  StorageService get _storage => Get.find<StorageService>();

  RxList<Track> get favorites => _storage.favoriteTracks;

  void toggleFavorite(Track track) {
    _storage.toggleFavorite(track);
    if (_storage.isFavorite(track)) {
      Get.snackbar('Favorites', '${track.name} added to favorites');
    } else {
      Get.snackbar('Favorites', '${track.name} removed from favorites');
    }
  }

  bool isFavorite(Track track) {
    return _storage.isFavorite(track);
  }
}
