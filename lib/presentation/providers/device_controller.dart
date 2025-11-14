import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:my_iot_app/domain/usecases/listen_device_update.dart';

import '../../domain/entities/smart_device.dart';
import '../../domain/usecases/toggle_device.dart';
import '../../domain/usecases/update_temperature.dart';

class DeviceController extends StateNotifier<List<SmartDevice>> {
  final ListenDeviceUpdates listenUpdates;
  final ToggleDevice toggleDeviceUC;
  final UpdateTemperature updateTempUC;

  StreamSubscription? _sub;

  DeviceController(this.listenUpdates, this.toggleDeviceUC, this.updateTempUC)
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
    _sub = listenUpdates().listen(_onMqttMessage);
  }

  void _onMqttMessage(Map<String, dynamic> msg) {
    final id = msg['id'];
    final i = state.indexWhere((e) => e.id == id);
    if (i == -1) return;

    final d = state[i];
    final updated = d.copyWith(
      isOn: msg['isOn'] ?? d.isOn,
      temperature: msg['temperature'] ?? d.temperature,
      battery: msg['battery'] ?? d.battery,
    );

    state = [...state]..[i] = updated;
  }

  void togglePower(int index) {
    final d = state[index];
    final newState = d.copyWith(isOn: !d.isOn);
    state = [...state]..[index] = newState;
    toggleDeviceUC(d.id, newState.isOn);
  }

  void setTemperature(int index, int value) {
    final d = state[index];
    final newDevice = d.copyWith(temperature: value, isOn: true);
    state = [...state]..[index] = newDevice;
    updateTempUC(d.id, value);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
