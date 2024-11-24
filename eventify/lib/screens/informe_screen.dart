import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eventify/provider/pdf_generator.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/menu.dart';

class InformeScreen extends StatefulWidget {
  @override
  _InformeScreenState createState() => _InformeScreenState();
}

class _InformeScreenState extends State<InformeScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  List<String> eventTypes = [];
  final Map<String, bool> selectedTypes = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Método para cargar las categorías de forma asíncrona
  Future<void> _loadCategories() async {
    final response = await EventProvider.getCategories();

    if (response.statusCode == 200) {
      final List<dynamic> categories = json.decode(response.body)['data'];  // Extraemos la lista de categorías

      setState(() {
        // Mapear las categorías a una lista de strings (nombres de las categorías)
        eventTypes = categories.map<String>((category) {
          return category['name'] as String;  // Accede correctamente al campo 'name'
        }).toList();

        // Inicializa el mapa de tipos seleccionados con false
        for (var type in eventTypes) {
          selectedTypes[type] = false;
        }
      });
    } else {
      throw Exception("Error al cargar las categorías: ${response.statusCode}");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fecha de inicio
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(labelText: "Fecha de inicio"),
                readOnly: true,
                onTap: () => _selectDate(context, startDateController),
              ),
              const SizedBox(height: 16),
              // Fecha final
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(labelText: "Fecha final"),
                readOnly: true,
                onTap: () => _selectDate(context, endDateController),
              ),
              const SizedBox(height: 16),
              // Checkboxes para tipos de evento
              const Text("Tipos de evento:"),
              // Si las categorías aún no están cargadas, muestra un cargador
              if (eventTypes.isEmpty)
                const CircularProgressIndicator()
              else
                Column(
                  children: eventTypes.map((type) {
                    return CheckboxListTile(
                      title: Text(type),
                      value: selectedTypes[type],
                      onChanged: (value) {
                        setState(() {
                          selectedTypes[type] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _generatePdf,
                    child: const Text("Generar PDF"),
                  ),
                  ElevatedButton(
                    onPressed: _sendPdf,
                    child: const Text("Enviar PDF"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Menu(currentIndex: 2),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<List<Map<String, String>>> fetchAndParseEvents({
    required String startDate,
    required String endDate,
    required List<String> selectedTypes,
  }) async {
    final response = await EventProvider.getEvents();

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> eventosJson = jsonData["data"] is List ? jsonData["data"] : [];

      // Filtrar eventos por fecha y tipo
      final filteredEvents = eventosJson.where((event) {
        if (event is Map<String, dynamic>) {
          final startTime = event["start_time"];
          if (startTime == null) return false;

          // Intentar parsear la fecha del evento
          final eventDate = DateTime.tryParse(startTime);
          if (eventDate == null) {
            return false;
          }

          // Parsear las fechas de inicio y fin
          final parsedStartDate = DateTime.parse(startDate);
          final parsedEndDate = DateTime.parse(endDate);

          // Verificar si la fecha está en el rango
          final isDateInRange = eventDate.isAfter(parsedStartDate) && eventDate.isBefore(parsedEndDate);

          // Verificar si el tipo de evento está en los tipos seleccionados
          final isTypeSelected = selectedTypes.contains(event["category"]);

          return isDateInRange && isTypeSelected;
        }
        return false;
      }).toList();

      // Convertir la lista filtrada al formato adecuado para el PDF
      return filteredEvents.map((event) {
        if (event is Map<String, dynamic>) {
          return {
            "titulo": event["title"]?.toString() ?? "Sin título",
            "fecha": event["start_time"]?.toString() ?? "Sin fecha",
            "imagen": event["image_url"]?.toString() ?? "",
          };
        }
        return {
          "titulo": "Sin título",
          "fecha": "Sin fecha",
          "imagen": ""
        };
      }).toList();
    } else {
      throw Exception("Error al obtener los eventos: ${response.statusCode}");
    }
  }

  void _generatePdf() async {
    try {
      final selectedEventTypes = selectedTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final events = await fetchAndParseEvents(
        startDate: startDateController.text,
        endDate: endDateController.text,
        selectedTypes: selectedEventTypes,
      );

      final pdfGenerator = PdfGenerator();
      final pdfFile = await pdfGenerator.generatePdf(events);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF generado y guardado: ${pdfFile.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al generar el PDF: $e")),
      );
    }
  }

  void _sendPdf() async {
    try {
      final selectedEventTypes = selectedTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final events = await fetchAndParseEvents(
        startDate: startDateController.text,
        endDate: endDateController.text,
        selectedTypes: selectedEventTypes,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? "";
      final pdfGenerator = PdfGenerator();
      final pdfFile = await pdfGenerator.generatePdf(events);

      final emailSend = Email(
        subject: 'Informe de eventos',
        recipients: [email],
        body: 'Adjunto se encuentra el informe de eventos solicitado.',
        attachmentPaths: [pdfFile.path],
      );

      await FlutterEmailSender.send(emailSend);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF enviado por correo")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al enviar el PDF: $e")),
      );
    }
  }
}
