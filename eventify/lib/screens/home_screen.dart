import 'package:eventify/widgets/background.dart';
import 'package:flutter/material.dart';
import '../menu/menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        centerTitle: true,
        backgroundColor: const Color(0xff415993),
        // Color del AppBar
      ),
      body: const Background(
          child: Text(
        "Hola",
        style: TextStyle(fontSize: 25),
      )),

      //drawer: const Lateralmenu(),
      drawer: const Menu(),
    );
  }
}
