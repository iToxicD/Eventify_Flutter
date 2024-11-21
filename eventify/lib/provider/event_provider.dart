import 'dart:convert';

import 'package:intl/intl.dart';
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

    return response;
  }

  static Future<http.Response> getEventsByUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? userId = prefs.getString('user_id');

    var url = Uri.parse('$baseUrl/eventsByUser?id=$userId');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    var response = await http.post(url, headers: headers);

    return response;
  }

  static Future<http.Response> register($eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? userId = prefs.getString('user_id');
    DateTime registeredAt = DateTime.now();

    var url = Uri.parse('$baseUrl/registerEvent');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    var body = {
      "user_id": userId,
      "event_id": $eventId,
      "registered_at": DateFormat('yyyy-MM-dd HH:mm:ss').format(registeredAt),
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }

  static Future<http.Response> unregister($eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? userId = prefs.getString('user_id');

    var url = Uri.parse('$baseUrl/unregisterEvent');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    var body = {
      "user_id": userId,
      "event_id": $eventId,
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    return response;
  }

  static Future<http.Response> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var url = Uri.parse('$baseUrl/categories');
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    var response = await http.get(url, headers: headers);

    return response;
  }
}
