import '../entities/sensor_entity.dart';

abstract class SensorRepository {
  Stream<SensorEntity> listenRealTime();
}
