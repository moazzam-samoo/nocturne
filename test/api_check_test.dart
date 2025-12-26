import 'package:flutter_test/flutter_test.dart';
import 'package:jm_music/app/data/providers/jamendo_provider.dart';

void main() {
  test('Jamendo API fetches tracks successfully', () async {
    final provider = JamendoProvider();
    
    print('Attempting to fetch tracks...');
    try {
      final tracks = await provider.fetchTracks(limit: 5);
      
      print('Successfully fetched ${tracks.length} tracks.');
      if (tracks.isNotEmpty) {
        print('First track: ${tracks.first.name} by ${tracks.first.artistName}');
        print('Audio URL: ${tracks.first.audioUrl}');
      }
      
      expect(tracks.isNotEmpty, true);
    } catch (e) {
      print('Error fetching tracks: $e');
      fail('API call failed'); // Fail the test if exception occurs
    }
  });
}
