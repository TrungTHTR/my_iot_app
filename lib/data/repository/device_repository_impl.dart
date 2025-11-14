import '../../domain/repository/device_repository.dart';
import '../datasource/mqtt_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final MockMqttDataSource dataSource;

  DeviceRepositoryImpl(this.dataSource);

  @override
  Stream<Map<String, dynamic>> listenMqtt() => dataSource.messages;

  @override
  void publish(String topic, Map<String, dynamic> payload) {
    dataSource.publish(topic, payload);
  }
}
