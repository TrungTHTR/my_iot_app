import 'package:flutter/material.dart';
import '../../domain/entities/sensor_entity.dart';

class SensorCard extends StatelessWidget {
  final SensorEntity data;

  const SensorCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Temperature: ${data.temperature.toStringAsFixed(1)} °C",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              "Humidity: ${data.humidity.toStringAsFixed(1)} %",
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
