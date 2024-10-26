import 'package:eventify/screens/home_screen.dart';
import 'package:eventify/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventify/services/authentication.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // String email = '';
  // String password = '';

  // login() async {
  //   http.Response res = await Authentication.login(email, password);
  //   Map response = jsonDecode(res.body);
  //   if (res.statusCode == 200) {
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  // }

  @override
  Widget build(BuildContext context) {
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
                const messageWelcome(),
                const emailField(),
                const passwordField(),
                const SizedBox(height: 10),
                LoginButton(),
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

class messageWelcome extends StatelessWidget {
  const messageWelcome({super.key});

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

class emailField extends StatelessWidget {
  const emailField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        decoration: InputDecoration(
          icon: const Icon(Icons.email_outlined, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white, width: 5),
          ),
          labelText: 'Correo electronico',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
          suffixIconColor: Colors.white,
        ),
      ),
    );
  }
}

class passwordField extends StatelessWidget {
  const passwordField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        obscureText: true,
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
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String email = '';
        String password = '';
        http.Response res = await Authentication.login(email, password);
        if (res.statusCode == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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
            'Registrate aqui',
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
