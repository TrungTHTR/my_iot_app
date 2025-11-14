import '../repository/device_repository.dart';

class ListenDeviceUpdates {
  final DeviceRepository repo;

  ListenDeviceUpdates(this.repo);

  Stream<Map<String, dynamic>> call() {
    return repo.listenMqtt();
  }
}
