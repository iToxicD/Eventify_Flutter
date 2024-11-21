import 'dart:convert';
import 'package:eventify/widgets/eventlist_buttons.dart';
import 'package:eventify/widgets/menu.dart';
// import 'package:eventify/widgets/menu.dart'; // Archivo adaptado del BottomNavigationBar
import 'package:eventify/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/event_category_widget.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<dynamic> events = [];
  List<dynamic> filterEvents = [];
  String role = '';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchRole();
    await fetchEvents();
  }

  Future<void> fetchRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRole = prefs.getString('role');
    setState(() {
      role = savedRole ?? '';
    });
  }

  Future<void> fetchEvents() async {
    var response = await EventProvider.getEvents();

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      events = jsonResponse['data'];

      DateTime now = DateTime.now();
      events = events.where((event) {
        DateTime startTime = DateTime.parse(event['start_time']);
        return startTime.isAfter(now);
      }).toList();

      events.sort((a, b) {
        DateTime startTimeA = DateTime.parse(a['start_time']);
        DateTime startTimeB = DateTime.parse(b['start_time']);
        return startTimeB.compareTo(startTimeA);
      });

      setState(() {
        filterEvents = List.from(events);
      });
    }
  }

  void eventCategories(String category) {
    setState(() {
      if (category.isEmpty) {
        filterEvents = List.from(events);
      } else {
        filterEvents =
            events.where((event) => event['category'] == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Lista de Eventos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
        shadowColor: Colors.grey[700],
      ),
      floatingActionButton: EventlistButtons(
        categories: eventCategories,
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
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filterEvents.length,
                itemBuilder: (context, index) {
                  var event = filterEvents[index];
                  return Column(
                    children: [
                      EventCategoryWidget(
                        category: event['category'],
                        imageUrl: event['image_url'] ?? '',
                        title: event['title'] ?? 'Título no disponible',
                        startTime: DateTime.parse(event['start_time']),
                      ),
                      if (role == 'u')
                        ElevatedButton(
                          onPressed: () {
                            // Lógica para registrarse al evento
                          },
                          child: const Text('Registrarse'),
                        ),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: const Menu(currentIndex: 2),
    );
  }
}
