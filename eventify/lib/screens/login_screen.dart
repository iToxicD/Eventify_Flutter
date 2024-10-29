import 'dart:convert';
import 'package:eventify/screens/register_screen.dart';
import 'package:eventify/screens/userlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventify/services/authentication.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para los campos de texto
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          return Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff620091),
                  Color(0xff8a0db7),
                  Color(0xffb11adc)
                ],
              ),
            ),
            child: Stack(
              // Cambiamos a Stack para superponer el nuevo contenedor
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 300),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    height: double.infinity,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const MessageWelcome(),
                          const SizedBox(height: 40),
                          EmailField(controller: emailController),
                          PasswordField(controller: passwordController),
                          const SizedBox(height: 40),
                          LoginButton(
                              emailController: emailController,
                              passwordController: passwordController),
                          const SizedBox(height: 10),
                          const RegisterMessage(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MessageWelcome extends StatelessWidget {
  const MessageWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 100, left: 30),
      child: Text(
        '¡Bienvenido a Eventify!',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          icon: Icon(Icons.email_outlined, color: Colors.black),
          labelText: 'Correo electrónico',
          labelStyle: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  const PasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          icon: Icon(Icons.visibility_off, color: Colors.black),
          labelText: 'Contraseña',
          labelStyle: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    Key? key,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String email =
            emailController.text.trim(); // Obtener el texto del controlador
        String password =
            passwordController.text.trim(); // Obtener el texto del controlador

        if (email.isNotEmpty && password.isNotEmpty) {
          // Comprobar que los campos no estén vacíos
          http.Response res = await Authentication.login(email, password);
          Map response = jsonDecode(res.body);

          if (res.statusCode == 200) {
            // Puedes guardar el token aquí si lo necesitas
            Navigator.push(
              context,
              //MaterialPageRoute(builder: (context) => const HomeScreen()),
              MaterialPageRoute(builder: (context) => const UserListScreen()),
            );
          } else {
            // Mostrar un mensaje de error basado en la respuesta
            String message = response['message'];
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Mostrar un mensaje de error si los campos están vacíos
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Por favor completa todos los campos.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      },
      child: const Text(
        'Iniciar sesión',
        style: TextStyle(fontSize: 25, color: Colors.black),
      ),
    );
  }
}

class RegisterMessage extends StatelessWidget {
  const RegisterMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '¿No tienes cuenta?',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Regístrate aquí',
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.normal,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
