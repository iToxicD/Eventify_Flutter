import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {

  static const String baseUrl = 'https://eventify.allsites.es/public/api';

  static Future<http.Response> register(String name, String email, String password, String cPassword, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json',},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'c_password': cPassword,
        'role': role,
      }),
    );

    return response;
  }


  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password,
    };
    var body = json.encode(data);
    var url = Uri.parse('$baseUrl/login');
    var headers = {'Content-Type': 'application/json', 'Accept': 'application/json',};
    http.Response res = await http.post(url, headers: headers, body: body);

    if (res.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(res.body);
      String token = responseData['data']['token'];
      String role = responseData['data']['role'];
      int userId = responseData['data']['id'];

      // Guardar el token en shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('role', role);
      await prefs.setString('user_id', userId.toString());
      await prefs.setString('email', email);
    }

    return res;
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Elimina todos los valores guardados
  }
}
