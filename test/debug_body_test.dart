import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Print Body Test', () async {
    const String clientId = '709fa152';
    var url = Uri.parse('https://api.jamendo.com/v3.0/tracks/?client_id=$clientId&format=json&limit=1');
    print('Testing URL: $url');
    var response = await http.get(url);
    print('Response Body: ${response.body}');
    print('Headers: ${response.headers}');
  });
}
