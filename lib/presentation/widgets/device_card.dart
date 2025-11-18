import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_iot_app/presentation/widgets/bottomsheet_card.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../domain/entities/smart_device.dart';
import '../providers/device_controller.dart';

class DeviceCard extends ConsumerWidget {
  final SmartDevice device;
  final int index;
  const DeviceCard({super.key, required this.device, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = device.isOn;
    final gradient = isOn
        ? const LinearGradient(
            colors: [Color(0xFFFB923C), Color(0xFFEF4444)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF242424), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DeviceControlSheet(device: device, index: index),
      ),
      child: AnimatedContainer(
        constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isOn ? Colors.orange.withOpacity(.18) : Colors.black.withOpacity(.6),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top: small switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (_) => ref.read(deviceListProvider.notifier).toggleDevice(index),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(device.room, style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            // central icon + temp/battery
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // icon placeholder
                      Container(
                        height: 68,
                        width: 68,
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                        child: Icon(_chooseIcon(device.name), size: 38, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text('${device.temperature}°C', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircularPercentIndicator(
                      radius: 34.0,
                      lineWidth: 5.0,
                      percent: (device.battery.clamp(0, 100)) / 100,
                      center: Text('${device.battery}%'),
                      progressColor: Colors.green,
                      backgroundColor: Colors.white12,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _chooseIcon(String name) {
    if (name.toLowerCase().contains('kettle')) return Icons.electric_bike;
    if (name.toLowerCase().contains('coffee')) return Icons.coffee;
    if (name.toLowerCase().contains('rice')) return Icons.rice_bowl;
    if (name.toLowerCase().contains('wash')) return Icons.local_laundry_service;
    return Icons.devices;
  }
}
