import '../entities/sensor_entity.dart';
import '../repository/sensor_repository.dart';

class ListenSensorUseCase {
  final SensorRepository repository;

  ListenSensorUseCase(this.repository);

  Stream<SensorEntity> call() {
    return repository.listenRealTime();
  }
}
