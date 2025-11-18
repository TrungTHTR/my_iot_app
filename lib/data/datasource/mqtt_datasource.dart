import 'dart:async';
import 'dart:math';

import '../models/sensor_model.dart';

class MQTTFakeDatasource {
  //DB CONNECTION CAN BE HERE

  //Simulate MQTT REAL-TIME bằng Stream.periodic.
  Stream<SensorModel> listenFakeMQTT() {
    return Stream.periodic(const Duration(seconds: 1), (tick) {
      return SensorModel(
        temperature: 20 + (tick % 10).toDouble(), // giả lập
        humidity: 50 + (tick % 20).toDouble(),
      );
    });
  }
}

// Giả lập một MQTT Data Source với kết nối và gửi nhận tin nhắn.
class MockMqttDataSource {
  final _random = Random();
  final _incoming = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _incoming.stream;

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 300));

    Timer.periodic(const Duration(seconds: 5), (t) {
      final deviceId = 'device_${_random.nextInt(4)}';
      _incoming.add({
        "id": deviceId,
        "isOn": _random.nextBool(),
        "temperature": 40 + _random.nextInt(60),
        "battery": 30 + _random.nextInt(70),
      });
    });
  }

  void publish(String topic, Map<String, dynamic> payload) {
    Future.delayed(const Duration(milliseconds: 400), () {
      _incoming.add(payload);
    });
  }

  void dispose() => _incoming.close();
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
