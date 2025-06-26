import 'package:flutter/material.dart';

class MessageTemperature extends StatelessWidget {
  final List<String> messages;

  const MessageTemperature({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Text(
          messages.first,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      );
  }
}
