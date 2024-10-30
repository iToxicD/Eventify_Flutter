import 'package:flutter/material.dart';
import 'package:eventify/widgets/menu.dart'; // Importa el menú

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pantalla de Inicio',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xff620091),
              Color(0xff8a0db7),
              Color(0xffb11adc)
            ]),
          ),
        ), // Color del AppBar
      ),
      drawer: const Menu(), // Añade el menú aquí
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Center(
          child: Text(
            '¡Bienvenido a la aplicación!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
