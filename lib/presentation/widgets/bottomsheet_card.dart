import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_iot_app/domain/entities/smart_device.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../providers/device_controller.dart';

/// ---------- BOTTOM SHEET: Device Control ----------
class DeviceControlSheet extends ConsumerStatefulWidget {
  final SmartDevice device;
  final int index;
  const DeviceControlSheet({super.key, required this.device, required this.index});

  @override
  ConsumerState<DeviceControlSheet> createState() => _DeviceControlSheetState();
}

class _DeviceControlSheetState extends ConsumerState<DeviceControlSheet> {
  late double _temp;
  @override
  void initState() {
    super.initState();
    _temp = widget.device.temperature.toDouble().clamp(20, 100);
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(deviceListProvider)[widget.index];
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 60,
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(d.room, style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                  Switch(
                    value: d.isOn,
                    onChanged: (_) => ref.read(deviceListProvider.notifier).toggleDevice(widget.index),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: _tempertureShow2(d),
                // _tempertureShow(d)
              ),
              const SizedBox(height: 14),
              Slider(
                value: _temp,
                min: 20,
                max: 100,
                divisions: 80,
                label: '${_temp.toInt()}°C',
                onChanged: (v) => setState(() => _temp = v),
                onChangeEnd: (v) => ref.read(deviceListProvider.notifier).setTemperature(widget.index, v.toInt()),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton('Heating', Icons.local_fire_department, true),
                  _actionButton('Lighting', Icons.lightbulb, false),
                  _actionButton('Sound', Icons.volume_up, false),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Status', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1B1B1D), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Power', style: TextStyle(color: d.isOn ? Colors.white : Colors.white60)),
                    Text(d.isOn ? 'On' : 'Off', style: TextStyle(color: d.isOn ? Colors.greenAccent : Colors.white60)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tempertureShow(SmartDevice d) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: d.isOn
              ? [Colors.orange.shade300, Colors.orange.shade700, Colors.grey.shade800]
              : [Colors.grey.shade800, Colors.grey.shade900],
        ),
        boxShadow: [BoxShadow(color: d.isOn ? Colors.orange.withOpacity(.12) : Colors.black, blurRadius: 18)],
      ),
      child: Center(
        child: Text('${d.temperature}°C', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _tempertureShow2(SmartDevice d) {
    return CircularPercentIndicator(
      radius: 45.0,
      lineWidth: 4.0,
      percent: 0.10,
      center: Center(
        child: Text('${d.temperature}°C', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
      ),
      // progressColor: Colors.red,
      linearGradient: LinearGradient(
        colors: d.isOn
            ? [Colors.orange.shade300, Colors.orange.shade700, Colors.grey.shade800]
            : [Colors.grey.shade800, Colors.grey.shade900],
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, bool active) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? Colors.orange : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(text),
      ],
    );
  }
}
