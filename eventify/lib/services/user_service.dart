import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'https://eventify.allsites.es/public/api';

  static Future<http.Response> activateUser(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    Map<String, String> headers = {
      'Accept': 'application/json',
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };

    var body = json.encode({"id": id});
    var url = Uri.parse('$baseUrl/activate');
    var response = await http.post(url, headers: headers, body: body);

    print("Activar Usuario - Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response;
  }

  static Future<http.Response> deactivateUser(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      "Content-Type": "application/json",
    };

    var body = json.encode({"id": id});
    var url = Uri.parse('$baseUrl/deactivate');
    var response = await http.post(url, headers: headers, body: body);

    print("Desactivar Usuario - Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response;
  }

  static Future<http.Response> getUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var url = Uri.parse('$baseUrl/users');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    var response = await http.get(url, headers: headers);

    print("Obtener Usuarios - Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response;
  }

  static Future<http.Response> deleteUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var url = Uri.parse('$baseUrl/deleteUser');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    var body = json.encode({"id": userId});

    var response = await http.post(url, headers: headers, body: body);
    print(userId);
    print("Eliminar Usuario - Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response;
  }

  static Future<http.Response> updateUser(String userId, String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var url = Uri.parse('$baseUrl/updateUser');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    var body = jsonEncode({
      "id": userId,
      "name": newName,
    });

    var response = await http.post(url, headers: headers, body: body);
    print(userId);
    print(newName);
    print(token);
    print("Actualizar Usuario - Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response;
  }
}
