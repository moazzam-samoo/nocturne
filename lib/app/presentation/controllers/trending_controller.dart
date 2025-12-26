import 'package:get/get.dart';
import '../../domain/entities/track.dart';
import '../../data/providers/saavn_provider.dart';

class TrendingController extends GetxController {
  final SaavnProvider _provider = SaavnProvider();
  final RxList<Track> displayedTracks = <Track>[].obs; // Renamed from trendingTracks for clarity
  final RxBool isLoading = true.obs;
  final RxString selectedAlphabet = 'A'.obs;
  final List<String> alphabets = List.generate(26, (index) => String.fromCharCode(index + 65));

  @override
  void onInit() {
    super.onInit();
    fetchSongsByAlphabet('A');
  }

  Future<void> fetchSongsByAlphabet(String alphabet) async {
    try {
      if (selectedAlphabet.value != alphabet) {
         isLoading(true); // Only show loading if changing specific letters or initial load
      }
      selectedAlphabet.value = alphabet;
      
      // Use searchTracks to simulate "browsing" by letter
      final tracks = await _provider.searchTracks(alphabet);
      displayedTracks.value = tracks;
    } catch (e) {
      print('Alphabet Fetch Error: $e');
    } finally {
      isLoading(false);
    }
  }

  // Alias for pull-to-refresh to keep RefreshIndicator working
  Future<void> fetchTrending() async {
    await fetchSongsByAlphabet(selectedAlphabet.value);
  }
}
