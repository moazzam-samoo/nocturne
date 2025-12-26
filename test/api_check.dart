import 'package:captions/app/data/providers/jamendo_provider.dart';
import 'package:captions/app/data/models/track_model.dart';

void main() async {
  print("Testing Jamendo API...");
  final provider = JamendoProvider();
  
  try {
    print("Fetching Trending Music...");
    final tracks = await provider.getTrendingMusic();
    print("Successfully fetched ${tracks.length} trending tracks.");
    if (tracks.isNotEmpty) {
      print("First track: ${tracks[0].title} by ${tracks[0].artistName}");
      print("Audio URL: ${tracks[0].audioUrl}");
    }
  } catch (e) {
    print("Error fetching trending music: $e");
  }

  try {
    print("\nFetching Regional (Indian/Hindi) Music...");
    final regional = await provider.getRegionalMusic();
    print("Successfully fetched ${regional.length} regional tracks.");
    if (regional.isNotEmpty) {
      print("First track: ${regional[0].title} by ${regional[0].artistName}");
    }
  } catch (e) {
    print("Error fetching regional music: $e");
  }
}
