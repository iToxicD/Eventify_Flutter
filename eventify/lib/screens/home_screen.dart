import 'package:flutter/material.dart';
import '../menu/menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Screen",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xff415993),
        shadowColor: Colors.grey[400],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xff162340),
              Color(0xff415993),
            ]),
          ),
        ),
        // Color del AppBar
      ),
      body: const Text(
        " ola k ase cabesa",
        style: TextStyle(fontSize: 25),
      ),

      //drawer: const Lateralmenu(),
      drawer: const Menu(),
    );
  }
}
