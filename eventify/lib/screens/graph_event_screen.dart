import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
import 'package:eventify/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../widgets/menu.dart';

class GraphEventScreen extends StatefulWidget {
  @override
  _GraphEventScreenState createState() => _GraphEventScreenState();
}

class _GraphEventScreenState extends State<GraphEventScreen> {
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await findEvents(); // Asegura que los datos se carguen primero
    await findUserData();
    await findCategories();
    await getEventRegistrationCounts(selectCategory);
    print(
        "eventos id del organizador después de cargar datos: $eventsOfThisOrganizer");
  }

  // Lista de categorías disponibles
  Map<String, String> categories = {};
  List<dynamic> eventData = [];
  List<dynamic> userData = [];
  List<dynamic> eventsOfThisOrganizer = [];
  Map<String, int> eventsByMonth = {};
  bool status = true; // Para mostrar un mensaje, si no hay datos

  // Categoria que saldrá por defecto
  String selectCategory = "Music";

  // Obtiene los eventos creado por el organizador
  Future<void> findEvents() async {
    try {
      var response = await EventProvider.getEventsByOrganizer();

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          eventData = List<dynamic>.from(data['data']);
          eventsOfThisOrganizer = eventData.map((event) {
            return event['id'];
          }).toList();
          print("Eventos cargados: $eventData");
          print("IDs de eventos: $eventsOfThisOrganizer");
        });

        // Filtrar eventos de los últimos 4 meses
        DateTime actualDate = DateTime.now();
        DateTime fourMonths = actualDate.subtract(Duration(days: 120));

        var filteredEvents = eventData.where((event) {
          DateTime eventDate = DateTime.parse(event['start_time']);
          return eventDate.isAfter(fourMonths) &&
              eventDate.isBefore(actualDate);
        }).toList();
        print("Eventos cargados 4 meses: $filteredEvents");
        // Actualizar el estado con los eventos filtrados
        setState(() {
          eventData = filteredEvents;
        });
      } else {
        throw Exception('Error al cargar los eventos');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print("Error al cargar eventos: $e");
    }
  }

  // Filtra los eventos del organizador
  Future<void> findEventsByCategory(String categoryId) async {
    try {
      var response = await EventProvider.getEventsByOrganizer();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Eventos del organizador: ${jsonEncode(data['data'])}");
        setState(() {
          // Obtener los eventos
          eventData = List<dynamic>.from(data['data']);
          // Obtener el nombre de la categoría utilizando el ID
          String? categoryName = categories[categoryId];
          if (categoryName == null) {
            print("Categoría no encontrada para el ID: $categoryId");
            return;
          }

          // Filtrar los eventos para la categoría solicitada
          var filteredEvents = eventData.where((event) {
            return event['category_name'] == categoryName;
          }).toList();
          print("Eventos filtrados: $filteredEvents");

          // Actualizar el estado con los eventos filtrados
          eventData = filteredEvents;
        });
      } else {
        throw Exception('Error al cargar los eventos por categoría');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print("Error al cargar eventos por categoría: $e");
    }
  }

  // Obtiene informacion del usuario
  Future<void> findUserData() async {
    try {
      var response = await EventProvider.getEventsByUser();
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
        });
      } else {
        throw Exception('Error al cargar los datos de usuarios');
      }
    } catch (e) {
      print(e);
    }
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
        print("Categorías cargadas: $categories");
      });
    } else {
      print('Error al buscar categorias: ${response.body}');
    }
  }

  Future<Map<String, int>> getEventRegistrationCounts(
      String categoryName) async {
    // Mapa para almacenar los conteos de usuarios registrados por mes
    Map<String, int> registerByMonth = {
      "Mes 1": 0,
      "Mes 2": 0,
      "Mes 3": 0,
      "Mes 4": 0,
    };

    try {
      // Obtener eventos del organizador
      var response = await EventProvider.getEventsByOrganizer();
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> allEvents = List<dynamic>.from(data['data']);

        // Obtener la fecha actual y calcular el rango de 4 meses atrás
        DateTime now = DateTime.now();
        DateTime fourMonths = now.subtract(Duration(days: 120));

        // Filtrar eventos por categoría y fechas
        List<dynamic> filteredEvents = allEvents.where((event) {
          DateTime eventDate = DateTime.parse(event['start_time']);
          return event['category_name'] == categoryName &&
              eventDate.isAfter(fourMonths) &&
              eventDate.isBefore(now);
        }).toList();

        print("Eventos por categoría '$categoryName': $filteredEvents");

        // Mapear IDs de los eventos filtrados
        List<String> filteredEventIds =
            filteredEvents.map((event) => event['id'].toString()).toList();

        // Inicializar mapa de conteos para los eventos filtrados
        Map<String, int> eventRegistrationCounts = {
          for (var eventId in filteredEventIds) eventId: 0
        };

        // Obtener la lista de usuarios
        var usersResponse = await UserProvider.getUsers();
        if (usersResponse.statusCode == 200) {
          var usersData = jsonDecode(usersResponse.body);
          List<dynamic> users = List<dynamic>.from(usersData['data']);
          var filteredUsers = users.where((user) => user['role'] == 'u');

          // Contabilizar usuarios registrados en eventos filtrados
          for (var user in filteredUsers) {
            String userId = user['id'].toString();

            // Obtener eventos del usuario
            var userEventsResponse =
                await EventProvider.getEventsByUserId(userId);
            if (userEventsResponse.statusCode == 200) {
              var userEventsData = jsonDecode(userEventsResponse.body);
              List<String> userEventIds =
                  List<dynamic>.from(userEventsData['data'])
                      .map((event) => event['id'].toString())
                      .toList();

              // Comparar con los eventos filtrados y actualizar conteos
              for (var eventId in userEventIds) {
                if (eventRegistrationCounts.containsKey(eventId)) {
                  eventRegistrationCounts[eventId] =
                      eventRegistrationCounts[eventId]! + 1;
                }
              }
            }
          }
        }
        // Clasificar registros por mes
        for (var event in filteredEvents) {
          DateTime eventDate = DateTime.parse(event['start_time']);
          String eventId = event['id'].toString();
          int registerCount = eventRegistrationCounts[eventId] ?? 0;

          // Calcular a qué grupo de mes pertenece
          int monthGroup = (now.month - eventDate.month + 12) % 12;
          if (monthGroup >= 0 && monthGroup < 4) {
            String monthLabel = "Mes ${4 - monthGroup}";
            registerByMonth[monthLabel] =
                registerByMonth[monthLabel]! + registerCount;
          }
        }
      } else {
        print(
            "Error en el endpoint: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error al procesar los registros por categoría: $e");
    }

    print("Registros por mes: $registerByMonth");
    return registerByMonth;
  }

  List<DatosMes> getData() {
    // Filtra eventos solo por el nombre de la categoría
    List<dynamic> filterData = eventData
        .where((event) => event['category_name'] == selectCategory)
        .toList();
    // Mapea los datos filtrados, ignorando los valores inválidos
    return filterData
        .where((event) =>
            event.containsKey('month') && event.containsKey('registeredEvents'))
        .map((event) => DatosMes(event['month'], event['registeredEvents']))
        .toList();
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
                    value: categories.containsKey(selectCategory)
                        ? selectCategory
                        : categories.keys.first,
                    items: categories.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key, // id de la categoría
                        child: Text(entry.value), // Nombre de la categoría
                      );
                    }).toList(),
                    onChanged: (String? nuevaCategoriaId) async {
                      setState(() {
                        selectCategory = nuevaCategoriaId!;
                      });

                      await findEventsByCategory(selectCategory);
                    },
                  ),

            SizedBox(height: 16),

            // Gráfica
            Expanded(
              child: SfCartesianChart(
                title: ChartTitle(text: 'Registros en los últimos 4 meses'),
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Meses'),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Registros'),
                ),
                series: <ChartSeries>[
                  ColumnSeries<DatosMes, String>(
                    dataSource: getData(),
                    xValueMapper: (DatosMes dato, _) => dato.mes,
                    yValueMapper: (DatosMes dato, _) => dato.valor,
                    name: selectCategory,
                    color: Color(0xff620091),
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  )
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
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
