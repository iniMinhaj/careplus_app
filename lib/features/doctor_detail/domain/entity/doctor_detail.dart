import 'package:equatable/equatable.dart';

class DoctorDetail extends Equatable {
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
  final String bio;
  final List<String> education;
  final List<String> languages;
  final bool isAvailableToday;
  final List<DoctorSlotGroup> availableSlots;
  final List<DoctorReview> reviews;

  const DoctorDetail({
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
    required this.bio,
    required this.education,
    required this.languages,
    required this.isAvailableToday,
    required this.availableSlots,
    required this.reviews,
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
        bio,
        education,
        languages,
        isAvailableToday,
        availableSlots,
        reviews,
      ];
}

class DoctorSlotGroup extends Equatable {
  final String date;
  final List<String> slots;

  const DoctorSlotGroup({
    required this.date,
    required this.slots,
  });

  @override
  List<Object?> get props => [date, slots];
}

class DoctorReview extends Equatable {
  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  const DoctorReview({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  List<Object?> get props => [id, reviewerName, rating, comment, date];
}
