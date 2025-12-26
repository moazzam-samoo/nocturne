import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('Saavn API Check', () async {
    final url = Uri.parse('https://saavn.sumit.co/api/search/songs?query=Arijit+Singh&page=1&limit=5');
    print('Fetching: $url');
    final response = await http.get(url);
    
    print('Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
       print('Body Preview: ${response.body.substring(0, 200)}...');
       final data = json.decode(response.body);
       if (data['success'] == true && data['data'] != null && data['data']['results'] != null) {
          final results = data['data']['results'] as List;
          print('Found ${results.length} tracks');
          if (results.isNotEmpty) {
             final first = results.first;
             print('First Track: ${first['name']}');
             print('Image is List: ${first['image'] is List}');
             if (first['downloadUrl'] != null) {
                print('DownloadUrl found');
                String audioUrl = '';
                if (first['downloadUrl'] is List) {
                   final urls = first['downloadUrl'] as List;
                   audioUrl = urls.last['link'] ?? urls.last['url'];
                } else {
                   audioUrl = first['downloadUrl'];
                }
                print('Testing Audio URL: $audioUrl');
                if (audioUrl.isNotEmpty) {
                  try {
                    final audioResponse = await http.head(Uri.parse(audioUrl));
                    print('Audio URL Status: ${audioResponse.statusCode}');
                  } catch (e) {
                    print('Audio URL Error: $e');
                  }
                }
             }
          }
       } else {
         print('Structure mismatch or no success flag');
       }
    } else {
      print('Failed to fetch');
    }
  });
}
