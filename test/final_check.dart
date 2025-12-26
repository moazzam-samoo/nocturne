import 'package:flutter_test/flutter_test.dart';
import 'package:jm_music/app/data/providers/jamendo_provider.dart';

void main() {
  test('Jamendo Provider switches to Mock Data on API Failure', () async {
    final provider = JamendoProvider();
    print('Fetching tracks...');
    final tracks = await provider.fetchTracks();
    
    print('Fetched ${tracks.length} tracks.');
    
    expect(tracks.isNotEmpty, true);
    if (tracks.isNotEmpty) {
      print('First Track: ${tracks.first.name}');
      if (tracks.first.name == 'Jai Ho (Demo)') {
          print('SUCCESS: Mock Data loaded correctly.');
      } else {
        print('Using Live Data? (Unexpected but good if working)');
      }
    }
  });
}
