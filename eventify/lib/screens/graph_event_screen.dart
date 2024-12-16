import 'dart:convert';

import 'package:eventify/provider/event_provider.dart';
import 'package:eventify/widgets/eventlist_buttons.dart';
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
  }

  // Lista de categorías disponibles
  final List<String> category = ["Deportes", "Tecnología", "Música"];
  List<dynamic> eventData = [];
  bool status = true; // Para mostrar un mensaje, si no hay datos

  // Categoria que saldrá por defecto
  String selectCategory = "Deportes";

  Future<void> findEvents() async {
    try {
      var response = await EventProvider.getEventsByOrganizer();
      if (response.statusCode == 200) {
        setState(() {
          eventData = jsonDecode(response.body);
          status = false;
        });
      } else {
        throw Exception('Error al cargar los eventos: ${response.body}');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print(e);
    }
  }

  Future<void> findCategory() async {
    try {
      var response = await EventProvider.getCategories();
      if (response.statusCode == 200) {
        setState(() {
          eventData = jsonDecode(response.body);
          status = false;
        });
      } else {
        throw Exception('Error al cargar las categorias: ${response.body}');
      }
    } catch (e) {
      setState(() {
        status = false;
      });
      print(e);
    }
  }

  List<DatosMes> getData() {
    return eventData.map((event) {
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
              value: selectCategory,
              items: category.map((String categoria) {
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
