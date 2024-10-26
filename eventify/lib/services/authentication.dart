import 'package:eventify/network/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Authentication {
  // Registro de usuarios
  static Future<http.Response> register(String name, String email, String password, String cPassword, String role) async {
    final response = await http.post(
      Uri.parse('https://eventify.allsites.es/public/api/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json',},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'c_password': cPassword,
        'role': 'u',
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }


  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password,
    };
    var body = json.encode(data);
    var url = Uri.parse('$baseUrl/login');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json', // Asegurar que el servidor sepa que esperas JSON
    };

    http.Response res = await http.post(url, headers: headers, body: body);
    print(res.body);
    return res;
  }

}
