import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCategoryWidget extends StatelessWidget {
  final String category;
  final String imageUrl;
  final String title;
  final DateTime startTime;

  const EventCategoryWidget({super.key, 
    required this.category,
    required this.imageUrl,
    required this.title,
    required this.startTime,
  });

  Color _getBorderColor() {
    switch (category) {
      case 'Music':
        return const Color(0xFFFFD700); // Amarillo
      case 'Sport':
        return const Color(0xFFFF4500); // Naranja
      case 'Technology':
        return const Color(0xFF4CAF50); // Verde
      default:
        return Colors.grey; // Color por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _getBorderColor(), width: 5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del evento con bordes redondeados
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(15.0),
              width: double.infinity, // Ocupa todo el ancho disponible
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del evento
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Fecha del evento
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(startTime)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
