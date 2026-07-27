import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String bloodGroup;
  final String address;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.bloodGroup,
    required this.address,
  });

  @override
  @override
  List<Object?> get props =>
      [id, name, email, phone, photoUrl, bloodGroup, address];
}
