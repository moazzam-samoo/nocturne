import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  const customClientId = '7ce36c3b'; // User provided ID
  
  final uri = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$customClientId&format=json&limit=5&order=popularity_month&include=musicinfo');
  
  print("Hitting: $uri");
  
  try {
    final response = await http.get(uri);
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");
  } catch (e) {
    print("Error: $e");
  }
}
