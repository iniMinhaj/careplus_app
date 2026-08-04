import 'package:careplus/features/auth/domain/entity/emergency_contact.dart';

class EmergencyContactModel {
  final String name;
  final String relation;
  final String phone;

  const EmergencyContactModel({
    required this.name,
    required this.relation,
    required this.phone,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  EmergencyContact toEntity() =>
      EmergencyContact(name: name, relation: relation, phone: phone);
}
