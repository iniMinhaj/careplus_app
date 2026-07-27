import 'package:careplus/features/auth/domain/entity/user.dart';

import 'emergency_contact_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String address;
  final EmergencyContactModel? emergencyContact;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    this.emergencyContact,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        dateOfBirth: json['dateOfBirth'] ?? '',
        gender: json['gender'] ?? '',
        bloodGroup: json['bloodGroup'] ?? '',
        address: json['address'] ?? '',
        emergencyContact: json['emergencyContact'] != null
            ? EmergencyContactModel.fromJson(
                json['emergencyContact'] as Map<String, dynamic>)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodGroup: bloodGroup,
      address: address,
      emergencyContact: emergencyContact?.toEntity(),
      createdAt: createdAt,
    );
  }
}
