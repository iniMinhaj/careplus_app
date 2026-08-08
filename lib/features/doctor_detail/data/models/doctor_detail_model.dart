import '../../domain/entity/doctor_detail.dart';

class DoctorDetailModel {
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
  final List<DoctorSlotGroupModel> availableSlots;
  final List<DoctorReviewModel> reviews;

  DoctorDetailModel({
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

  factory DoctorDetailModel.fromJson(Map<String, dynamic> json) =>
      DoctorDetailModel(
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
        bio: json['bio'] ?? '',
        education: (json['education'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        languages: (json['languages'] as List? ?? [])
            .map((e) => e.toString())
            .toList(),
        isAvailableToday: json['isAvailableToday'] ?? false,
        availableSlots: (json['availableSlots'] as List? ?? [])
            .map((e) => DoctorSlotGroupModel.fromJson(e))
            .toList(),
        reviews: (json['reviews'] as List? ?? [])
            .map((e) => DoctorReviewModel.fromJson(e))
            .toList(),
      );

  DoctorDetail toEntity() => DoctorDetail(
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
        bio: bio,
        education: education,
        languages: languages,
        isAvailableToday: isAvailableToday,
        availableSlots: availableSlots.map((e) => e.toEntity()).toList(),
        reviews: reviews.map((e) => e.toEntity()).toList(),
      );
}

class DoctorSlotGroupModel {
  final String date;
  final List<String> slots;

  DoctorSlotGroupModel({required this.date, required this.slots});

  factory DoctorSlotGroupModel.fromJson(Map<String, dynamic> json) =>
      DoctorSlotGroupModel(
        date: json['date'] ?? '',
        slots: (json['slots'] as List? ?? []).map((e) => e.toString()).toList(),
      );

  DoctorSlotGroup toEntity() => DoctorSlotGroup(date: date, slots: slots);
}

class DoctorReviewModel {
  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final String date;

  DoctorReviewModel({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory DoctorReviewModel.fromJson(Map<String, dynamic> json) =>
      DoctorReviewModel(
        id: json['id'] ?? '',
        reviewerName: json['reviewerName'] ?? '',
        rating: (json['rating'] ?? 0).toDouble(),
        comment: json['comment'] ?? '',
        date: json['date'] ?? '',
      );

  DoctorReview toEntity() => DoctorReview(
        id: id,
        reviewerName: reviewerName,
        rating: rating,
        comment: comment,
        date: date,
      );
}
