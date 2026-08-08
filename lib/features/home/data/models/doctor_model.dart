import '../../domain/entity/doctor.dart';

class DoctorModel {
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

  DoctorModel({
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

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'],
        name: json['name'],
        specializationId: json['specializationId'],
        specializationName: json['specializationName'],
        photoUrl: json['photoUrl'],
        experienceYears: json['experienceYears'] ?? 0,
        rating: (json['rating'] ?? 0).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        consultationFee: json['consultationFee'] ?? 0,
        currency: json['currency'] ?? 'BDT',
        hospital: json['hospital'] ?? '',
        location: json['location'] ?? '',
        isAvailableToday: json['isAvailableToday'] ?? false,
      );

  Doctor toEntity() => Doctor(
        id: id,
        name: name,
        specializationId: specializationId,
        specializationName: specializationName,
        photoUrl: photoUrl,
        experienceYears: experienceYears,
        rating: rating,
        reviewCount: reviewCount,
        consultationFee: consultationFee,
        currency: currency,
        hospital: hospital,
        location: location,
        isAvailableToday: isAvailableToday,
      );
}
