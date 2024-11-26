import 'dart:convert';
import 'package:eventify/widgets/event_category_widget.dart';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/widgets/showDialog.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';

class RegisteredEventsScreen extends StatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  _RegisteredEventsScreenState createState() => _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState extends State<RegisteredEventsScreen> {
  List<dynamic> registeredEvents = [];

  @override
  void initState() {
    super.initState();
    fetchRegisteredEvents();
  }

  Future<void> fetchRegisteredEvents() async {
    try {
      // Obtener eventos registrados por el usuario
      var userResponse = await EventProvider.getEventsByUser();
      if (userResponse.statusCode != 200) {
        showErrorSnackBar('Error al cargar eventos registrados');
        return;
      }
      Map<String, dynamic> userJsonResponse = jsonDecode(userResponse.body);
      List<int> registeredIds = List<int>.from(
        userJsonResponse['data'].map((event) => event['id']),
      );

      // Obtener todos los eventos
      var eventsResponse = await EventProvider.getEvents();
      if (eventsResponse.statusCode != 200) {
        showErrorSnackBar('Error al cargar todos los eventos');
        return;
      }
      Map<String, dynamic> eventsJsonResponse = jsonDecode(eventsResponse.body);
      List<dynamic> allEvents = eventsJsonResponse['data'];

      // Filtrar eventos registrados
      setState(() {
        registeredEvents = allEvents
            .where((event) => registeredIds.contains(event['id']))
            .toList();
      });
    } catch (e) {
      showErrorSnackBar('Error de conexión');
    }
  }

  Future<void> unregisterEvent(dynamic event) async {
    try {
      var response = await EventProvider.unregister(event['id']);
      if (response.statusCode == 200) {
        setState(() {
          registeredEvents.remove(event);
        });
        showSuccessSnackBar('Te has borrado del evento');
      } else {
        showErrorSnackBar('Error al cancelar el registro');
      }
    } catch (e) {
      showErrorSnackBar('Error de conexión');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white))),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Eventos Registrados',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
        shadowColor: Colors.grey[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff620091), Color(0xff8a0db7), Color(0xffb11adc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: registeredEvents.isEmpty
            ? const Center(
                child: Text(
                  'No estás registrado en ningún evento',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: registeredEvents.length,
                itemBuilder: (context, index) {
                  var event = registeredEvents[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => showEventDialog(
                          event: event,
                          unRegisterEvents: () => unregisterEvent(event),
                        ),
                      );
                    },
                    child: EventCategoryWidget(
                      category: event['category'] ?? 'Categoría no disponible',
                      imageUrl: event['image_url'] ?? '',
                      title: event['title'] ?? 'Título no disponible',
                      startTime: DateTime.parse(event['start_time']),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: EventCategoryWidget(category: category, imageUrl: imageUrl, title: title, startTime: startTime),
      bottomNavigationBar: const Menu(currentIndex: 1), // Asegúrate de ajustar el índice según el orden.
    );
    
  }
}
