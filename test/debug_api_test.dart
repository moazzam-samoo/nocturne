import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jm_music/app/data/providers/jamendo_provider.dart';

void main() {
  test('Jamendo API Debug Test', () async {
    const String clientId = '7ce36c3b';
    
    // Variation 1: Pop tags
    var url = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=5&tags=pop&include=musicinfo');
    print('Testing Tags=Pop: $url');
    var response = await http.get(url);
    print('Pop Count: ${(json.decode(response.body)['results'] as List).length}');

    // Variation 2: Popularity Order (No tags)
    url = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=5&order=popularity_total');
    print('Testing Order=Popularity: $url');
    response = await http.get(url);
    print('Popularity Count: ${(json.decode(response.body)['results'] as List).length}');
    
    // Variation 3: Search
    var url3 = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=5&namesearch=love');
    var response3 = await http.get(url3);
    var data3 = json.decode(response3.body);
    print('Testing Search=love: $url3');
    print('Search Count: ${data3['results'].length}');

    // Variation 4: Indian Tags
    var url4 = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=5&tags=Indian+Hindi+Bollywood&include=musicinfo');
    var response4 = await http.get(url4);
    var data4 = json.decode(response4.body);
    print('Testing Indian Tags: $url4');
    print('Indian Count: ${data4['results'].length}');

    // Variation 5: Hollywood Tags
    var url5 = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=5&tags=Pop+Rock+Dance&include=musicinfo');
    var response5 = await http.get(url5);
    var data5 = json.decode(response5.body);
    print('Testing Hollywood Tags: $url5');
    print('Hollywood Count: ${data5['results'].length}');

    // 2. Try the Provider with specific tags
    final provider = JamendoProvider();
    print('\nTesting Provider with "Indian+Hindi"...');
    final tracks = await provider.fetchTracks(limit: 5);
    print('Provider Fetched: ${tracks.length}');
  });
}
