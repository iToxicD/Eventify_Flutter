import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EventProvider {
  static const String baseUrl = 'https://eventify.allsites.es/public/api';

  static Future<http.Response> getEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var url = Uri.parse('$baseUrl/events');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    var response = await http.get(url, headers: headers);
    print(response);
    return response;
  }
}