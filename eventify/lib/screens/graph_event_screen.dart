import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
import 'package:eventify/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../widgets/menu.dart';

class GraphEventScreen extends StatefulWidget {
  @override
  _GraphEventScreenState createState() => _GraphEventScreenState();
}

class _GraphEventScreenState extends State<GraphEventScreen> {

  List<DatosMes> datosMes = [];
  String selectedCategory = "1";
  Map<String, String> categories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await findCategories();
    await actualizarDatos(selectedCategory);
  }

  Future<void> actualizarDatos(String categoria) async {
    setState(() {
      _isLoading = true;
    });
    var graphData = await getGraphData(categoria);
    setState(() {
      datosMes = graphData.entries.map((entry) {
        return DatosMes(entry.key, entry.value);
      }).toList();
      _isLoading = false;
    });

  }

  // Obtiene los eventos creado por el organizador
  Future<List<dynamic>> getEventsOfThisOrganizer(String categoryId) async {
    List<dynamic> eventsOfThisOrganizer = [];

    var response = await EventProvider.getEventsByOrganizer();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> eventData = data['data'];
      eventsOfThisOrganizer = eventData.map((event) {
        return event;
      }).toList();
    }

    // Calcular el rango entre hace 3 meses y el final del mes actual
    DateTime now = DateTime.now();
    DateTime startOfFourMonthsAgo = DateTime(now.year, now.month - 3, 1);
    DateTime endOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

    // Pasar de id de categoria a nombre
    String? categoryName = categories[categoryId];

    // Filtrar eventos por categoría y fechas
    List<dynamic> filteredEvents = eventsOfThisOrganizer.where((event) {
      DateTime eventDate = DateTime.parse(event['start_time']);
      return event['category_name'] == categoryName &&
          eventDate.isAfter(startOfFourMonthsAgo) &&
          eventDate.isBefore(endOfCurrentMonth);
    }).toList();

    return filteredEvents;
  }


  // Obtiene las categorias
  Future<void> findCategories() async {
    var response = await EventProvider.getCategories();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var categoriesData = List<Map<String, dynamic>>.from(data['data']);
      setState(() {
        // Convierte la lista de mapas en un Map
        categories = {
          for (var category in categoriesData)
            category['id'].toString(): category['name']
        };
      });
    } else {
      print('Error al obtener las categorias: ${response.body}');
    }
  }

  Future<List<dynamic>> getEventsByUser(userId) async {
    List<dynamic> eventsId = [];
    var response = await EventProvider.getEventsByUserId(userId);

    if (response.statusCode == 200) {
      var userEventsData = jsonDecode(response.body);
      eventsId = (userEventsData['data'])
          .map((event) => event['id'].toString())
          .toList();
    }

    return eventsId;
  }

  Future<Map<String, int>> getGraphData(String categoryId) async {
    // Inicializar el mapa con los nombres de los últimos cuatro meses
    DateTime now = DateTime.now();
    Map<String, int> registerByMonth = {
      DateFormat('MMMM').format(DateTime(now.year, now.month - 3)): 0, // Hace 3 meses
      DateFormat('MMMM').format(DateTime(now.year, now.month - 2)): 0, // Hace 2 meses
      DateFormat('MMMM').format(DateTime(now.year, now.month - 1)): 0, // Mes anterior
      DateFormat('MMMM').format(DateTime(now.year, now.month)): 0,     // Mes actual
    };

    // Obtener los eventos del organizador
    List<dynamic> events = await getEventsOfThisOrganizer(categoryId);

    // Extraer los IDs de los eventos
    List<String> eventIds = events.map((event) => event['id'].toString()).toList();

    // Obtener la lista de usuarios
    var usersResponse = await UserProvider.getUsers();
    if (usersResponse.statusCode == 200) {
      var usersData = jsonDecode(usersResponse.body);
      List<dynamic> users = List<dynamic>.from(usersData['data']);
      var filteredUsers = users.where((user) => user['role'] == 'u');

      // Obtener los eventos registrados de cada usuario
      for (var user in filteredUsers) {
        String userId = user['id'].toString();
        List<dynamic> usersEvents = await getEventsByUser(userId);

        // Comprobar si los eventos del usuario coinciden con los del organizador
        for (var eventId in usersEvents) {
          if (eventIds.contains(eventId)) {
            // Obtener el start_time del evento
            var event = events.firstWhere((e) => e['id'].toString() == eventId);
            DateTime eventDate = DateTime.parse(event['start_time']);

            // Determinar el mes del evento y actualizar el contador
            String eventMonth = DateFormat('MMMM').format(eventDate);
            if (registerByMonth.containsKey(eventMonth)) {
              registerByMonth[eventMonth] = registerByMonth[eventMonth]! + 1;
            }
          }
        }
      }
    }

    return registerByMonth;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Gráficas',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff620091),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Desplegable para la categoría
            Text(
              "Selecciona una categoría:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            categories.isEmpty
                ? Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
              value: selectedCategory,
              items: categories.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? nuevaCategoriaId) async {
                setState(() {
                  selectedCategory = nuevaCategoriaId!;
                });
                await actualizarDatos(selectedCategory);
              },
            ),
            SizedBox(height: 16),

            // Gráfica
            Expanded(
              child: Stack(
                children: [
                  SfCartesianChart(
                    title: ChartTitle(text: 'Registros en los últimos 4 meses'),
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(text: 'Meses'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: 'Registros'),
                      interval: 1,
                    ),
                    series: <ChartSeries>[
                      ColumnSeries<DatosMes, String>(
                        dataSource: datosMes,
                        xValueMapper: (DatosMes dato, _) => dato.mes,
                        yValueMapper: (DatosMes dato, _) => dato.valor,
                        name: selectedCategory,
                        color: Color(0xff620091),
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.white.withOpacity(0.7), // Fondo translúcido
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const Menu(currentIndex: 0),
    );
  }
}

// Clase para estructurar los datos de la gráfica
class DatosMes {
  final String mes;
  final int valor;

  DatosMes(this.mes, this.valor);
}
