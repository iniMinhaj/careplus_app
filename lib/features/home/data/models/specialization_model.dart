import '../../domain/entity/specialization.dart';

class SpecializationModel {
  final String id;
  final String name;
  final String icon;
  final int doctorCount;

  SpecializationModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.doctorCount,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) =>
      SpecializationModel(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        doctorCount: json['doctorCount'] ?? 0,
      );

  Specialization toEntity() => Specialization(
        id: id,
        name: name,
        icon: icon,
        doctorCount: doctorCount,
      );
}
