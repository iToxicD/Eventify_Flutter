import 'package:flutter/material.dart';
import 'package:eventify/screens/home_screen.dart';
import 'package:eventify/screens/userlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleMiddleware {
  static Future<void> authorize(BuildContext context, Widget screen) async {
    // Obtenemos el rol del usuario autenticado desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('role');
    print("User role from SharedPreferences: $userRole");


    // Si la pantalla es 'UserListScreen' y el usuario no es admin, redirigir a 'HomeScreen'
    if (screen is UserListScreen && userRole != 'a') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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
