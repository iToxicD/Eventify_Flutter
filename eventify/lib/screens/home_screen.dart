import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xff162340), Color(0xff415993)])),
        child: const Column(children: [
          SizedBox(height: 100),
          Padding(
            padding: EdgeInsets.only(right: 200, left: 30),
            child: Text(
              '¡Bienvenido a Eventify!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto blanco
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
