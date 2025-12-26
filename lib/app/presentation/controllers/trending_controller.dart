import 'package:get/get.dart';
import '../../domain/entities/track.dart';
import '../../data/providers/saavn_provider.dart';

class TrendingController extends GetxController {
  final SaavnProvider _provider = SaavnProvider();
  final RxList<Track> trendingTracks = <Track>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrending();
  }

  Future<void> fetchTrending() async {
    try {
      isLoading(true);
      // We can randomize the query or rotate between "Trending", "Top 2024", "Viral"
      final tracks = await _provider.getTrending();
      trendingTracks.value = tracks;
    } catch (e) {
      print('Trending Error: $e');
    } finally {
      isLoading(false);
    }
  }
}
