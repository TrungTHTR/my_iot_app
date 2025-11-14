import '../repository/device_repository.dart';

class ToggleDevice {
  final DeviceRepository repo;

  ToggleDevice(this.repo);

  void call(String deviceId, bool isOn) {
    repo.publish(
      'devices/$deviceId/set',
      {"id": deviceId, "isOn": isOn},
    );
  }
}
