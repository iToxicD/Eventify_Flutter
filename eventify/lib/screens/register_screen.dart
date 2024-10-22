import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = '';
  String password = '';

  final TextEditingController _nameField = TextEditingController();
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 45, 80),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              const Text(
                'Eventify',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto blanco
                ),
              ),
              const SizedBox(height: 130),
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 5)),
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    suffixIconColor: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 5)),
                    labelText: 'Correo electronico',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    suffixIconColor: Colors.white),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 5)),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    suffixIconColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
