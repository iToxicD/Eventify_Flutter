import 'package:flutter/material.dart';
import 'package:eventify/menu/menu.dart'; // Importa el menú

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de Inicio'),
        backgroundColor: const Color(0xff415993), // Color del AppBar
      ),
      drawer: const Menu(), // Añade el menú aquí
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff162340), // Color superior
              Color(0xff415993), // Color inferior
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text(
            'Bienvenido a la aplicación!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
