import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String name;
  final String specializationId;
  final String specializationName;
  final String photoUrl;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final int consultationFee;
  final String currency;
  final String hospital;
  final String location;
  final bool isAvailableToday;

  const Doctor({
    required this.id,
    required this.name,
    required this.specializationId,
    required this.specializationName,
    required this.photoUrl,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.currency,
    required this.hospital,
    required this.location,
    required this.isAvailableToday,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        specializationId,
        specializationName,
        photoUrl,
        experienceYears,
        rating,
        reviewCount,
        consultationFee,
        currency,
        hospital,
        location,
        isAvailableToday,
      ];
}
