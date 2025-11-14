import '../repository/device_repository.dart';

class UpdateTemperature {
  final DeviceRepository repo;

  UpdateTemperature(this.repo);

  void call(String deviceId, int value) {
    repo.publish(
      'devices/$deviceId/set',
      {"id": deviceId, "temperature": value, "isOn": true},
    );
  }
}
