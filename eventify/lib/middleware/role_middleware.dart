import 'package:eventify/screens/eventlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventify/screens/userlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleMiddleware {
  static Future<void> authorize(BuildContext context, Widget screen) async {
    // Obtenemos el rol del usuario autenticado desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('role');


    // Si la pantalla es 'UserListScreen' y el usuario no es admin, redirigir a 'EventlistScreen'
    if (screen is UserListScreen && userRole != 'a') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventListScreen()),
      );
    } else {
      // Si tiene permisos, navegar a la pantalla solicitada
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }
}
