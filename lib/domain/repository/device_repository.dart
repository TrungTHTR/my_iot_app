import '../entities/smart_device.dart';

abstract class DeviceRepository {
  Stream<Map<String, dynamic>> listenMqtt();
  void publish(String topic, Map<String, dynamic> payload);
}
