import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff162340),
            Color(0xff415993),
          ],
        ),
      ),
      child: child,
    );
  }
}
