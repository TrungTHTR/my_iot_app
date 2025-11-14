import '../../domain/entities/sensor_entity.dart';

class SensorModel extends SensorEntity {
  SensorModel({
    required super.temperature,
    required super.humidity,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      temperature: json["temperature"],
      humidity: json["humidity"],
    );
  }
}
