import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String name = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color.fromARGB(255, 3, 45, 80),
      // ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff162340), Color(0xff415993)])),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Padding(
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
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 5)),
                      labelText: 'Nombre',
                      labelStyle:
                          const TextStyle(color: Colors.white, fontSize: 20),
                      suffixIconColor: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      icon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 5)),
                      labelText: 'Correo electronico',
                      labelStyle:
                          const TextStyle(color: Colors.white, fontSize: 20),
                      suffixIconColor: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 5)),
                      labelText: 'Contraseña',
                      labelStyle:
                          const TextStyle(color: Colors.white, fontSize: 20),
                      suffixIconColor: Colors.white),
                ),
              ),
              const SizedBox(height: 1),
              ElevatedButton(
                onPressed: () {
                  // Acción
                },
                child: const Text(
                  'Registrarse',
                  style: TextStyle(fontSize: 25, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
