import 'dart:convert';
import 'package:eventify/screens/register_screen.dart';
import 'package:eventify/screens/userlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventify/services/authentication.dart';

import '../middleware/role_middleware.dart';

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
                colors: [Color(0xff162340), Color(0xff415993)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                const MessageWelcome(),
                EmailField(controller: emailController),
                PasswordField(controller: passwordController),
                const SizedBox(height: 10),
                LoginButton(
                    emailController: emailController,
                    passwordController: passwordController),
                const SizedBox(height: 10),
                const RegisterMessage(),
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
          color: Colors.white,
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
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        controller: controller, // Asignar el controlador aquí
        style:
            const TextStyle(color: Colors.white), // Color del texto ingresado
        decoration: InputDecoration(
          icon: const Icon(Icons.email_outlined, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 5),
          ),
          labelText: 'Correo electrónico',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
          suffixIconColor: Colors.white,
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
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        controller: controller, // Asignar el controlador aquí
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.password_outlined, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 5),
          ),
          labelText: 'Contraseña',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
          suffixIconColor: Colors.white,
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

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
            RoleMiddleware.authorize(context, const UserListScreen());
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
          style: TextStyle(fontSize: 18, color: Colors.white),
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
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
