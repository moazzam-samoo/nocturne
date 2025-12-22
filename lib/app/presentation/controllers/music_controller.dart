import 'package:get/get.dart';
import '../../domain/entities/track.dart';
import '../../domain/usecases/get_music.dart';
import '../../domain/usecases/search_music.dart';

class MusicController extends GetxController {
  final GetTrendingMusic getTrendingMusic;
  final GetRegionalMusic getRegionalMusic;
  final SearchMusic searchMusicUseCase;

  MusicController({
    required this.getTrendingMusic,
    required this.getRegionalMusic,
    required this.searchMusicUseCase,
  });

  // Observables
  var trendingTracks = <Track>[].obs;
  var regionalTracks = <Track>[].obs;
  var searchResults = <Track>[].obs;
  
  var isTrendingLoading = false.obs;
  var isRegionalLoading = false.obs;
  var isSearchLoading = false.obs;

  var trendingError = ''.obs;
  var regionalError = ''.obs;
  var searchError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrendingMusic();
    fetchRegionalMusic();
  }

  void fetchTrendingMusic() async {
    try {
      isTrendingLoading.value = true;
      trendingError.value = '';
      final tracks = await getTrendingMusic();
      trendingTracks.assignAll(tracks);
    } catch (e) {
      trendingError.value = e.toString();
    } finally {
      isTrendingLoading.value = false;
    }
  }

  void fetchRegionalMusic() async {
    try {
      isRegionalLoading.value = true;
      regionalError.value = '';
      final tracks = await getRegionalMusic();
      regionalTracks.assignAll(tracks);
    } catch (e) {
      regionalError.value = e.toString();
    } finally {
      isRegionalLoading.value = false;
    }
  }

  void search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      isSearchLoading.value = true;
      searchError.value = '';
      final tracks = await searchMusicUseCase(query);
      searchResults.assignAll(tracks);
    } catch (e) {
      searchError.value = e.toString();
    } finally {
      isSearchLoading.value = false;
    }
  }
}
