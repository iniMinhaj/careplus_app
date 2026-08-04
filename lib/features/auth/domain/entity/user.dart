import 'package:equatable/equatable.dart';

import 'emergency_contact.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String address;
  final EmergencyContact? emergencyContact;
  final DateTime? createdAt;

  const User({
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

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        photoUrl,
        dateOfBirth,
        gender,
        bloodGroup,
        address,
        emergencyContact,
        createdAt,
      ];
}
