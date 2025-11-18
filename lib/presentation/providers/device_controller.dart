import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_iot_app/data/datasource/mqtt_datasource.dart';

import '../../domain/entities/smart_device.dart';

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
  // final ListenDeviceUpdates listenUpdates;
  // final ToggleDevice toggleDeviceUC;
  // final UpdateTemperature updateTempUC;

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

  // DeviceController(this.listenUpdates, this.toggleDeviceUC, this.updateTempUC)
  //   : super([
  //       SmartDevice(
  //         id: 'device_0',
  //         name: 'Electric kettle',
  //         room: 'Kitchen',
  //         isOn: true,
  //         temperature: 58,
  //         battery: 100,
  //       ),
  //       SmartDevice(id: 'device_1', name: 'Coffee machine', room: 'Kitchen', isOn: false, temperature: 0, battery: 95),
  //       SmartDevice(id: 'device_2', name: 'Rice cooker', room: 'Kitchen', isOn: false, temperature: 0, battery: 80),
  //       SmartDevice(id: 'device_3', name: 'Washing machine', room: 'Laundry', isOn: false, temperature: 0, battery: 70),
  //     ]) {
  //   _sub = listenUpdates().listen(_onMqttMessage);
  // }

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

  // void togglePower(int index) {
  //   final d = state[index];
  //   final newState = d.copyWith(isOn: !d.isOn);
  //   state = [...state]..[index] = newState;
  //   toggleDeviceUC(d.id, newState.isOn);
  // }

  // void setTemperature(int index, int value) {
  //   final d = state[index];
  //   final newDevice = d.copyWith(temperature: value, isOn: true);
  //   state = [...state]..[index] = newDevice;
  //   updateTempUC(d.id, value);
  // }

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
