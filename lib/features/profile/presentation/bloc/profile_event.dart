import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String name;
  final String phone;
  final String bloodGroup;
  final String address;

  const ProfileUpdateRequested({
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.address,
  });

  @override
  List<Object?> get props => [name, phone, bloodGroup, address];
}
