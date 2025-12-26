import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track_model.dart';

class SaavnProvider {
  static const String _baseUrl = 'https://saavn.sumit.co/api';

  Future<List<TrackModel>> searchTracks(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search/songs?query=$query&page=1&limit=20');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // API returns "success": true
        if (data['success'] == true && data['data'] != null && data['data']['results'] != null) {
          final List results = data['data']['results'];
          return results.map((json) => _mapJsonToTrack(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Saavn API Error: $e');
      return [];
    }
  }

  Future<List<TrackModel>> getTrending() async {
     try {
      return await searchTracks('Trending');
    } catch (e) {
      return [];
    }
  }

  TrackModel _mapJsonToTrack(Map<String, dynamic> json) {
    // Helper to get image URL (usually a list of objects or strings)
    String imageUrl = '';
    if (json['image'] != null && (json['image'] as List).isNotEmpty) {
      // API returns list of { quality: "500x500", link: "..." }
      // We want the highest quality, usually the last one or explicitly 500x500
      final images = json['image'] as List;
      imageUrl = images.last['link'] ?? images.last['url']; 
    }

    // Helper to get audio URL (downloadUrl list)
    String audioUrl = '';
    if (json['downloadUrl'] != null && (json['downloadUrl'] as List).isNotEmpty) {
        final urls = json['downloadUrl'] as List;
        // Search for 320kbps, then 160kbps, then just take last
        var bestUrlObj = urls.firstWhere((u) => u['quality'] == '320kbps', orElse: () => null);
        bestUrlObj ??= urls.firstWhere((u) => u['quality'] == '160kbps', orElse: () => urls.last);
        
        audioUrl = bestUrlObj['link'] ?? bestUrlObj['url'];
    }

    // Handle artists
    String artist = 'Unknown Artist';
    if (json['primaryArtists'] != null) {
        artist = json['primaryArtists'].toString();
    }

    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      artistName: artist,
      albumImage: imageUrl,
      audioUrl: audioUrl,
      duration: json['duration'] != null ? int.tryParse(json['duration'].toString()) ?? 0 : 0,
      album: json['album'] != null && json['album']['name'] != null ? json['album']['name'] : (json['albumName'] ?? ''),
      year: json['year'] ?? '',
      genre: json['language'] ?? 'Unknown', // Sometimes language serves as genre in this API
      releaseDate: json['releaseDate'] ?? '',
      popularity: json['playCount']?.toString() ?? '',
      hasLyrics: json['hasLyrics'] == 'true' || json['hasLyrics'] == true,
    );
  }
}
