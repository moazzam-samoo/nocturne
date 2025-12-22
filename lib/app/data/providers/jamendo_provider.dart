import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track_model.dart';
import '../../domain/entities/track.dart';

class JamendoProvider {
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';
  static const String _clientId = '709fa152'; // Test Client ID

  Future<List<Track>> getTrendingMusic({int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&order=popularity_month&include=musicinfo&tags=pop'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return TrackModel.fromJsonList(data['results']);
      }
      return [];
    } else {
      throw Exception('Failed to load music');
    }
  }

  Future<List<Track>> searchMusic(String query, {int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&order=popularity_week&namesearch=$query&include=musicinfo'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return TrackModel.fromJsonList(data['results']);
      }
      return [];
    } else {
      throw Exception('Failed to search music');
    }
  }
  
  // Specific fetch for Indian/Hindi tags as requested
  Future<List<Track>> getRegionalMusic({int limit = 20}) async {
     final response = await http.get(
      Uri.parse('$_baseUrl/tracks/?client_id=$_clientId&format=json&limit=$limit&order=popularity_week&tags=hindi+indian&include=musicinfo'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return TrackModel.fromJsonList(data['results']);
      }
      return [];
    } else {
       // Fallback to empty list or throw, depending on preference. 
       // For now, let's treat it as empty result if tag search fails.
       return [];
    }
  }
}
