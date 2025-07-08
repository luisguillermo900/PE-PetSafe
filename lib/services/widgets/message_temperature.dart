import 'package:flutter/material.dart';
import 'dart:convert';

class MessageTemperature extends StatelessWidget {
  final List<String> messages;

  const MessageTemperature({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {

    DataTemperatura? data;

    if (messages.isNotEmpty && messages.first.isNotEmpty) {
      try {
        final Map<String, dynamic> dataTem = jsonDecode(messages.first);
        data = DataTemperatura.fromJson(dataTem);
      } catch (e) {
        debugPrint('Error al decodificar JSON: $e');
      }
    }
    
    return Center(
      widthFactor: 5,
      heightFactor: 1,
      child: Column(
        children: [
          if (data != null)
            Text(
              '${data.temperatura} °C',
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(240, 255, 255, 255),
              ),
            )
          else
            const Text(
              'No hay mensajes',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(240, 255, 255, 255),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class DataTemperatura {
  final String temperatura;

  DataTemperatura({required this.temperatura});

  factory DataTemperatura.fromJson(Map<String, dynamic> json) {
    return DataTemperatura(
      temperatura: json['temperatura'].toString(),
    );
  }
}

