import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController maxAttendeesController = TextEditingController();
  String? selectedCategory;
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializa los campos con los datos del evento
    titleController.text = widget.event['title'];
    descriptionController.text = widget.event['description'];
    startTimeController.text = widget.event['start_time'];
    endTimeController.text = widget.event['end_time'];
    locationController.text = widget.event['location'];
    priceController.text = widget.event['price'].toString();
    imageUrlController.text = widget.event['image_url'];
    latitudeController.text = widget.event['latitude']?.toString() ?? '';
    longitudeController.text = widget.event['longitude']?.toString() ?? '';
    maxAttendeesController.text = widget.event['max_attendees']?.toString() ?? '';
    selectedCategory = widget.event['category_id'].toString();

    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      var response = await EventProvider.getCategories();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;

          // Asegura que selectedCategory sea válido
          if (categories.any((category) => category['id'].toString() == selectedCategory)) {
            selectedCategory = widget.event['category_id'].toString();
          } else {
            selectedCategory = null; // O un valor por defecto
          }
        });
      } else {
        throw Exception('Error fetching categories: ${response.body}');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      // Obtener los valores de los campos de texto
      Map<String, dynamic> updatedEventData = {
        'id': widget.event['id'],
        'organizer_id': widget.event['organizer_id'], // Asumí que también es parte del evento
        'title': titleController.text,
        'description': descriptionController.text,
        'category_id': selectedCategory,
        'start_time': startTimeController.text,
        'end_time': endTimeController.text,
        'location': locationController.text,
        'latitude': widget.event['latitude'] ?? '', // Si no tienes latitud, usa una cadena vacía
        'longitude': widget.event['longitude'] ?? '', // Lo mismo con longitud
        'max_attendees': widget.event['max_attendees'] ?? '', // Si no tienes, usa vacío
        'price': priceController.text,
        'image_url': imageUrlController.text,
      };

      try {
        var response = await EventProvider.updateEvent(updatedEventData);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento actualizado con éxito.')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error actualizando evento: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Evento', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff620091),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoría'),
                value: selectedCategory,
                items: categories
                    .map((category) => DropdownMenuItem(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) => value == null
                    ? 'Por favor, selecciona una categoría'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: startTimeController,
                decoration: const InputDecoration(labelText: 'Fecha y hora de inicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la fecha de inicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: endTimeController,
                decoration: const InputDecoration(labelText: 'Fecha y hora de fin'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la fecha de fin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la ubicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el precio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la URL de la imagen';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: latitudeController,
                decoration: const InputDecoration(labelText: 'Latitud'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: longitudeController,
                decoration: const InputDecoration(labelText: 'Longitud'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: maxAttendeesController,
                decoration: const InputDecoration(labelText: 'Máximo de asistentes'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _updateEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      backgroundColor: const Color(0xff620091),
                    ),
                    child: const Text(
                      'Actualizar Evento',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
