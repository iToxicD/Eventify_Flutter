import 'dart:convert';
import 'package:eventify/screens/create_event_screen.dart';
import 'package:eventify/widgets/event_category_widget.dart';
import 'package:eventify/widgets/menu.dart';
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventListOrganizerScreen extends StatefulWidget {
  const EventListOrganizerScreen({super.key});

  @override
  _EventListOrganizerScreenState createState() =>
      _EventListOrganizerScreenState();
}

class _EventListOrganizerScreenState extends State<EventListOrganizerScreen> {
  List<dynamic> events = [];
  List<String> eventTypes = [];
  final Map<String, bool> selectedTypes = {};

  @override
  void initState() {
    super.initState();
    refreshEvents();
    fetchCategories();
  }

  Future<void> refreshEvents() async {
    await fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      var eventsResponse = await EventProvider.getEventsByOrganizer();
      if (eventsResponse.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(eventsResponse.body);
        List<dynamic> fetchedEvents = jsonResponse['data'];

        // Filtrar eventos para excluir los eliminados (deleted == 1)
        fetchedEvents = fetchedEvents
            .where((event) {
          DateTime start = DateTime.parse(event['start_time']);
          return start.isAfter(DateTime.now()) && event['deleted'] != 1;
        })
            .toList()
          ..sort((a, b) {
            DateTime startA = DateTime.parse(a['start_time']);
            DateTime startB = DateTime.parse(b['start_time']);
            return startA.compareTo(startB);
          });

        setState(() {
          events = fetchedEvents;
        });
      } else {
        showErrorSnackBar('Error al cargar eventos creados');
      }
    } catch (e) {
      showErrorSnackBar('Error de conexión');
    }
  }

  Future<void> fetchCategories() async {
    final response = await EventProvider.getCategories();
    if (response.statusCode == 200) {
      final List<dynamic> categories = json.decode(response.body)['data'];
      setState(() {
        eventTypes = categories.map<String>((category) => category['name'] as String).toList();
        for (var type in eventTypes) {
          selectedTypes[type] = false;
        }
      });
    } else {
      showErrorSnackBar("Error al cargar las categorías: ${response.statusCode}");
    }
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void showEventDetailsModal(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EventDetailModal(event: event, refreshEvents: refreshEvents);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Eventos creados',
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
        child: events.isEmpty
            ? const Center(
          child: Text(
            'No tienes eventos futuros',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return GestureDetector(
              onTap: () => showEventDetailsModal(context, event),
              child: EventCategoryWidget(
                category: event['category_name'] ?? 'Sin categoría',
                imageUrl: event['image_url'] ?? '',
                title: event['title'] ?? 'Sin título',
                startTime: DateTime.parse(event['start_time']),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateEventForm(context),
        backgroundColor: const Color(0xff8a0db7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }

  void showCreateEventForm(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEventScreen()),
    );

    // Si result no es nulo, significa que se ha creado un evento
    if (result != null && result) {
      fetchEvents(); // Refresca la lista de eventos
      showSuccessSnackBar('Evento creado exitosamente');
    }
  }

}

class EventDetailModal extends StatelessWidget {
  final Map<String, dynamic> event;
  final Future<void> Function() refreshEvents;

  const EventDetailModal({Key? key, required this.event, required this.refreshEvents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            event['title'] ?? 'Sin título',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(event['description'] ?? 'Sin descripción'),
          const SizedBox(height: 16),
          Text('Fecha de inicio: ${event['start_time']}'),
          Text('Fecha de fin: ${event['end_time']}'),
          Text('Ubicación: ${event['location']}'),
          Text('Precio: ${event['price']} \$'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Editar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDeleteConfirmation(context, event['id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, int eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este evento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await EventProvider.deleteEvent(eventId);
                refreshEvents(); // Actualiza la lista de eventos
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
