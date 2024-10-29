import 'dart:convert';
import 'package:eventify/screens/login_screen.dart';
import 'package:eventify/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String role = '';

  createAccount() async {
    try {
      http.Response res = await Authentication.register(name, email, password, password, role);

      // Decodificar la respuesta JSON
      Map response =
          jsonDecode(res.body); // Esto lanzará un error si no es un JSON válido

      if (res.statusCode == 200 && response['success']) {
        // Imprimir los datos en la consola
        print('Registro exitoso:');
        print('Nombre: ${response['data']['name']}');
        print('Email: ${response['data']['email']}');
        print('Role: ${response['data']['role']}');
        print('ID: ${response['data']['id']}');

        // Redirigir al Login
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      } else {
        // Manejar el error (mostrar mensaje)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Error en el registro')),
        );
      }
    } catch (e) {
      print('Error: $e'); // Imprimir error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la solicitud: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double height = constraints.maxHeight;

          return Container(
            width: double.infinity,
            height: double.infinity,
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
                NameField(onChanged: (value) => name = value),
                EmailField(onChanged: (value) => email = value),
                PasswordField(onChanged: (value) => password = value),
                ConfirmPasswordField(onChanged: (value) => confirmPassword = value),
                RoleField(onChanged: (value) => role = value ?? 'u'),
                RegisterButton(onPressed: createAccount),
                SizedBox(height: height * 0.02),
                const LoginMessage(),
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

class NameField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const NameField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.account_box_outlined, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          labelText: 'Nombre',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
          suffixIconColor: Colors.white,
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const EmailField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.email_outlined, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          labelText: 'Correo electrónico',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
          suffixIconColor: Colors.white,
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const PasswordField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        obscureText: true,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.password_outlined, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          labelText: 'Contraseña',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
          suffixIconColor: Colors.white,
        ),
      ),
    );
  }
}

class ConfirmPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ConfirmPasswordField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: TextFormField(
        obscureText: true,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: const Icon(Icons.lock_outline, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          labelText: 'Confirmar Contraseña',
          labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
          suffixIconColor: Colors.white,
        ),
      ),
    );
  }
}

class RoleField extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  const RoleField({super.key, required this.onChanged});

  @override
  _RoleFieldState createState() => _RoleFieldState();
}

class _RoleFieldState extends State<RoleField> {
  String selectedRole = 'u'; // Rol preseleccionado

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          labelText: 'Seleccione su rol',
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'u', child: Text("Usuario")),
          DropdownMenuItem(value: 'o', child: Text("Organizador")),
        ],
        onChanged: (value) {
          setState(() {
            selectedRole = value!;
          });
          widget.onChanged(value);
        },
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10),
        hint: const Text(
          "Seleccione su rol",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}


class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text(
        'Registrarse',
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}

class LoginMessage extends StatelessWidget {
  const LoginMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '¿Ya tienes una cuenta?',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            'Inicia sesión',
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
