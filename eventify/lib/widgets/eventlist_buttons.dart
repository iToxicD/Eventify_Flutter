import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class EventlistButtons extends StatefulWidget {
  const EventlistButtons({super.key});

  @override
  _EventlistButtonsState createState() => _EventlistButtonsState();
}

class _EventlistButtonsState extends State<EventlistButtons> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Colors.white,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      spacing: 10,
      spaceBetweenChildren: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.music_note),
          label: 'Musica',
          onTap: () => print('Categoria musica'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.sports_gymnastics),
          label: 'Deporte',
          onTap: () => print('Categoria deporte'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.phone_android),
          label: 'Tecnología',
          onTap: () => print('Categoria tecnologia'),
        ),
      ],
    );
  }
}
