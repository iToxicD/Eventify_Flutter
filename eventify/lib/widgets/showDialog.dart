import 'package:flutter/material.dart';

class showEventDialog extends StatelessWidget {
  final Map<String, dynamic> event;

  const showEventDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event['title'] ?? 'Título no disponible'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['image_url'] != null && event['image_url'].isNotEmpty)
              Image.network(event['image_url']),
            Text('Categoría: ${event['category'] ?? 'No disponible'}'),
            const SizedBox(height: 10),
            Text('Descripción: ${event['description'] ?? 'No disponible'}'),
            const SizedBox(height: 10),
            Text(
                'Fecha: ${event['start_time'] != null ? DateTime.parse(event['start_time']) : 'No disponible'}'),
            const SizedBox(height: 10),
            Text('Ubicación: ${event['location'] ?? 'No disponible'}'),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
