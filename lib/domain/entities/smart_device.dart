class SmartDevice {
  final String id;
  final String name;
  final String room;
  final bool isOn;
  final int temperature;
  final int battery;

  SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.isOn,
    required this.temperature,
    required this.battery,
  });

  SmartDevice copyWith({
    String? id,
    String? name,
    String? room,
    bool? isOn,
    int? temperature,
    int? battery,
  }) {
    return SmartDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      temperature: temperature ?? this.temperature,
      battery: battery ?? this.battery,
    );
  }
}
