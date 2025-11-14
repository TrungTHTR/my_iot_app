// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'presentation/pages/home_page.dart';

// void main() {
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(debugShowCheckedModeBanner: false, home: const HomePage());
//   }
// }

// main.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// ---------- MODELS ----------
class SmartDevice {
  final String id;
  final String name;
  final String room;
  final bool isOn;
  final int temperature; // example for kettle
  final int battery; // example extra

  SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.isOn,
    required this.temperature,
    required this.battery,
  });

  SmartDevice copyWith({String? id, String? name, String? room, bool? isOn, int? temperature, int? battery}) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      temperature: temperature ?? this.temperature,
      battery: battery ?? this.battery,
    );
  }
}

/// ---------- MOCK MQTT SERVICE (simulates broker) ----------
class MockMqttService {
  final _random = Random();
  final StreamController<Map<String, dynamic>> _incoming = StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _incoming.stream;

  // Simulate connect
  Future<void> connect() async {
    // pretend to connect
    await Future.delayed(const Duration(milliseconds: 300));
    // start simulated device updates
    Timer.periodic(const Duration(seconds: 5), (t) {
      // send random updates for demonstration
      final deviceId = 'device_${_random.nextInt(4)}';
      final payload = {
        'id': deviceId,
        'isOn': _random.nextBool(),
        'temperature': 40 + _random.nextInt(60),
        'battery': 30 + _random.nextInt(70),
      };
      _incoming.add(payload);
    });
  }

  // Simulate publish (when app toggles or changes)
  void publish(String topic, Map<String, dynamic> payload) {
    // for demo: echo back message after short delay to simulate device ack
    Future.delayed(const Duration(milliseconds: 500), () {
      final ack = Map<String, dynamic>.from(payload);
      ack['id'] ??= 'device_0';
      _incoming.add(ack);
    });
  }

  void dispose() {
    _incoming.close();
  }
}

/// ---------- RIVERPOD: providers ----------
final mqttProvider = Provider<MockMqttService>((ref) {
  final svc = MockMqttService();
  svc.connect();
  ref.onDispose(() => svc.dispose());
  return svc;
});

final deviceListProvider = StateNotifierProvider<DeviceController, List<SmartDevice>>((ref) {
  final mqtt = ref.read(mqttProvider);
  return DeviceController(mqtt);
});

class DeviceController extends StateNotifier<List<SmartDevice>> {
  final MockMqttService mqtt;
  StreamSubscription? _sub;

  DeviceController(this.mqtt)
    : super([
        SmartDevice(
          id: 'device_0',
          name: 'Electric kettle',
          room: 'Kitchen',
          isOn: true,
          temperature: 58,
          battery: 100,
        ),
        SmartDevice(id: 'device_1', name: 'Coffee machine', room: 'Kitchen', isOn: false, temperature: 0, battery: 95),
        SmartDevice(id: 'device_2', name: 'Rice cooker', room: 'Kitchen', isOn: false, temperature: 0, battery: 80),
        SmartDevice(id: 'device_3', name: 'Washing machine', room: 'Laundry', isOn: false, temperature: 0, battery: 70),
      ]) {
    _sub = mqtt.messages.listen(_onMqttMessage);
  }

  void _onMqttMessage(Map<String, dynamic> msg) {
    final id = msg['id'] as String?;
    if (id == null) return;
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final current = state[index];
    final updated = current.copyWith(
      isOn: msg['isOn'] ?? current.isOn,
      temperature: msg['temperature'] ?? current.temperature,
      battery: msg['battery'] ?? current.battery,
    );
    state = [...state]..[index] = updated;
  }

  void toggleDevice(int index) {
    final d = state[index];
    final updated = d.copyWith(isOn: !d.isOn);
    state = [...state]..[index] = updated;

    // Publish to MQTT (simulated)
    mqtt.publish('devices/${d.id}/set', {'id': d.id, 'isOn': updated.isOn});
  }

  void setTemperature(int index, int value) {
    final d = state[index];
    final updated = d.copyWith(temperature: value, isOn: true);
    state = [...state]..[index] = updated;
    mqtt.publish('devices/${d.id}/set', {'id': d.id, 'temperature': value, 'isOn': true});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// ---------- MAIN APP ----------
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Demo',
      theme: ThemeData.dark(
        useMaterial3: false,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF0B0B0D), cardColor: const Color(0xFF1B1B1D)),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ---------- DASHBOARD PAGE ----------
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Smart Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Row(children: const [Icon(Icons.cloud_done), SizedBox(width: 8), Text('Sync 88%')]),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GridView.builder(
          itemCount: devices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .95,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            final d = devices[i];
            return DeviceCard(device: d, index: i);
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Expanded(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
            ),
            Expanded(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.science)),
            ),
            Expanded(
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- DEVICE CARD WIDGET ----------
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
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: d.isOn
                          ? [Colors.orange.shade300, Colors.orange.shade700, Colors.grey.shade800]
                          : [Colors.grey.shade800, Colors.grey.shade900],
                    ),
                    boxShadow: [
                      BoxShadow(color: d.isOn ? Colors.orange.withOpacity(.12) : Colors.black, blurRadius: 18),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${d.temperature}°C',
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
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
