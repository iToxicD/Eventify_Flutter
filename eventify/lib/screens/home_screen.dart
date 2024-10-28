import 'package:eventify/screens/config_users.dart';
import 'package:eventify/widgets/background.dart';
import 'package:eventify/widgets/lateralMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
      drawer: Menu(),
    );
  }
}
