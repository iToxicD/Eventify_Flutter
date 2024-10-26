import 'package:eventify/network/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Authentication {
  // Registro de usuarios
  static Future<http.Response> register(
      String name, String email, String password) async {
    // Map de los datos que se necesitan para registrarse
    Map data = {
      "name": name,
      "email": email,
      "password": password,
    };
    // Transforma el map en un json (para el Laravel)
    var body = json.encode(data);
    // Url del endpoint (baseUrl se encuentra en el archivo api.dart)
    var url = Uri.parse('$baseUrl/register');
    // Envia la peticion POST
    http.Response res = await http.post(url, headers: header, body: body);
    // Debug
    print(res.body);
    return res;
  }

  // Este metodo funciona de la misma manera que el anterior
  // pero para el inicio de sesión.
  static Future<http.Response> login(String email, String password) async {
    Map data = {
      "email": email,
      "password": password,
    };
    var body = json.encode(data);
    var url = Uri.parse('$baseUrl/login');
    // Revisar
    http.Response res = await http.post(url, headers: header, body: body);
    print(res.body);
    return res;
  }
}
