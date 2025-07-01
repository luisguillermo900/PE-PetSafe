import 'package:flutter/material.dart';

class MessageTemperature extends StatelessWidget {
  final List<String> messages;

  const MessageTemperature({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(24)),
      color: const Color.fromARGB(255, 77, 142, 255),
      shadowColor: const Color.fromARGB(255, 0, 0, 0),
      child: Center(
        widthFactor: 5,
        heightFactor: 1,
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Text(
              messages.join('\n'),
              style: const TextStyle(fontSize: 14, color: Color.fromARGB(240, 255, 255, 255)),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
