import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track_model.dart';

class JamendoProvider {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '7ce36c3b'; 

  Future<List<TrackModel>> fetchTracks({int limit = 20, String tags = 'Indian+Hindi'}) async {
    final url = Uri.parse('$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&tags=$tags&include=musicinfo&imagesize=500');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check for API-level errors (like Suspended Key)
        if (data['headers'] != null && data['headers']['status'] == 'failed') {
          print('Jamendo API Error: ${data['headers']['error_message']}');
          return _getMockTracks(); // Fallback to mock data
        }

        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((json) => TrackModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
      return _getMockTracks(); // Fallback on network error too
    }
  }
  
  Future<List<TrackModel>> searchTracks(String query) async {
     final url = Uri.parse('$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=20&namesearch=$query&include=musicinfo&imagesize=500');
      try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
         if (data['headers'] != null && data['headers']['status'] == 'failed') {
          return _getMockTracks().where((t) => t.name.toLowerCase().contains(query.toLowerCase())).toList();
        }

        if (data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map((json) => TrackModel.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to search tracks: ${response.statusCode}');
      }
    } catch (e) {
       return _getMockTracks().where((t) => t.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  List<TrackModel> _getMockTracks() {
    return [
      TrackModel(
        id: '1',
        name: 'Jai Ho (Demo)',
        artistName: 'A.R. Rahman',
        albumImage: 'https://i.scdn.co/image/ab67616d0000b273707ea5b8023ac77d31756ed4', 
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // Free test audio
        duration: 240,
      ),
      TrackModel(
        id: '2',
        name: 'Tum Hi Ho',
        artistName: 'Arijit Singh',
        albumImage: 'https://i.scdn.co/image/ab67616d0000b273a0ae55a6d914d87216692040',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        duration: 200,
      ),
       TrackModel(
        id: '3',
        name: 'Kun Faya Kun',
        artistName: 'Mohit Chauhan',
        albumImage: 'https://c.saavncdn.com/408/Rockstar-Hindi-2011-20221212023539-500x500.jpg',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        duration: 320,
      ),
       TrackModel(
        id: '4',
        name: 'Kesariya',
        artistName: 'Pritam, Arijit',
        albumImage: 'https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        duration: 250,
      ),
      TrackModel(
        id: '5',
        name: 'Rahtaan Lambiyan',
        artistName: 'Jubin Nautiyal',
        albumImage: 'https://c.saavncdn.com/238/Shershaah-Original-Motion-Picture-Soundtrack--Hindi-2021-20210815181610-500x500.jpg',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        duration: 250,
      ),
    ];
  }
}
