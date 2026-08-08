import 'package:equatable/equatable.dart';

import '../../../domain/entity/doctor.dart';

enum DoctorListStatus { initial, loading, success, empty, failure }

class DoctorListState extends Equatable {
  final DoctorListStatus status;
  final List<Doctor> doctors;
  final String searchQuery;
  final String? specializationId;
  final double? minRating;
  final bool? availableOnly;
  final int? maxFee;
  final String? errorMessage;

  const DoctorListState({
    this.status = DoctorListStatus.initial,
    this.doctors = const [],
    this.searchQuery = '',
    this.specializationId,
    this.minRating,
    this.availableOnly,
    this.maxFee,
    this.errorMessage,
  });

  const DoctorListState.initial() : this();

  bool get hasActiveFilters =>
      minRating != null || availableOnly == true || maxFee != null;

  DoctorListState copyWith({
    DoctorListStatus? status,
    List<Doctor>? doctors,
    String? searchQuery,
    String? specializationId,
    bool clearSpecializationId = false,
    double? minRating,
    bool clearMinRating = false,
    bool? availableOnly,
    bool clearAvailableOnly = false,
    int? maxFee,
    bool clearMaxFee = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DoctorListState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      searchQuery: searchQuery ?? this.searchQuery,
      specializationId: clearSpecializationId
          ? null
          : (specializationId ?? this.specializationId),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      availableOnly:
          clearAvailableOnly ? null : (availableOnly ?? this.availableOnly),
      maxFee: clearMaxFee ? null : (maxFee ?? this.maxFee),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctors,
        searchQuery,
        specializationId,
        minRating,
        availableOnly,
        maxFee,
        errorMessage,
      ];
}
