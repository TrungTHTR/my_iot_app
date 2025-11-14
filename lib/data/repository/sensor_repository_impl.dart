import '../../domain/entities/sensor_entity.dart';
import '../../domain/repository/sensor_repository.dart';
import '../datasource/mqtt_datasource.dart';

class SensorRepositoryImpl implements SensorRepository {
  final MQTTFakeDatasource datasource;

  SensorRepositoryImpl(this.datasource);
  //TODO LIST HERE
  @override
  Stream<SensorEntity> listenRealTime() {
    return datasource.listenFakeMQTT();
  }
}
