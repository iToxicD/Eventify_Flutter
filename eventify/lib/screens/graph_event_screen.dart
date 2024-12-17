import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
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
    findEvents();
    findUserData();
    findCategories();
  }

  // Lista de categorías disponibles
  Map<String, String> categories = {};
  List<dynamic> eventData = [];
  List<dynamic> userData = [];
  bool status = true; // Para mostrar un mensaje, si no hay datos

  // Categoria que saldrá por defecto
  String selectCategory = "Technology";

  Future<void> findEvents() async {
    try {
      var response = await EventProvider.getEventsByOrganizer();
      if (response.statusCode == 200) {
        setState(() {
          eventData = jsonDecode(response.body);
          status = false;
          print(jsonEncode(eventData));
        });
      } else {
        throw Exception('Error al cargar los eventos');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print(e);
    }
  }

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

  Future<void> findCategories() async {
    var response = await EventProvider.getCategories();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
       var categoriesData = List<Map<String, dynamic>>.from(data['data']);
      setState(() {
      // Convierte la lista de mapas en un Map<String, String>
      categories = { 
        for (var category in categoriesData) 
          category['id'].toString(): category['name']
      };
      print("Categorías cargadas: $categories");
    });
    } else {
      print('Error fetching categories: ${response.body}');
    }
    
  }

  List<DatosMes> getData() {
    List<dynamic> filterData = eventData
        .where((event) => event['category_id'] == selectCategory)
        .toList();
    print("Eventos filtrados (${selectCategory}): ${jsonEncode(filterData)}");
    if (filterData.isEmpty) return [];
    return filterData.map((event) {
      return DatosMes(event['month'], event['registeredEvents']);
    }).toList();
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
            DropdownButton<String>(
              value: categories.containsValue(selectCategory) ? selectCategory : null,
              items: categories.values.map((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (String? nuevaCategoria) {
                setState(() {
                  selectCategory = nuevaCategoria!;
                });
                findEvents();
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
