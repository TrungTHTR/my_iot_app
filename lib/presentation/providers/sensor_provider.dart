import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/mqtt_datasource.dart';
import '../../domain/entities/sensor_entity.dart';
import '../../data/repository/sensor_repository_impl.dart';
import '../../domain/usecases/ListenSensorUseCase.dart';

final sensorProvider = StreamProvider<SensorEntity>((ref) {
  final usecase = ListenSensorUseCase(
    SensorRepositoryImpl(MQTTFakeDatasource()),
  );
  return usecase();
});
