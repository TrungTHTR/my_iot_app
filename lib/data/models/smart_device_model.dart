import '../../domain/entities/smart_device.dart';

class SmartDeviceModel extends SmartDevice {
  SmartDeviceModel({
    required super.id,
    required super.name,
    required super.room,
    required super.isOn,
    required super.temperature,
    required super.battery,
  });

  factory SmartDeviceModel.fromJson(Map<String, dynamic> json) {
    return SmartDeviceModel(
      id: json["id"],
      name: json["name"],
      room: json["room"],
      isOn: json["isOn"],
      temperature: json["temperature"],
      battery: json["battery"],
    );
  }
}
