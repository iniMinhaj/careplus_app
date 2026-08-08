import 'package:equatable/equatable.dart';

sealed class DoctorListEvent extends Equatable {
  const DoctorListEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load and pull-to-refresh both use this event.
class DoctorListRequested extends DoctorListEvent {
  /// True for pull-to-refresh, which should drop the active category
  /// filter and show all doctors again.
  final bool resetSpecializationFilter;

  const DoctorListRequested({this.resetSpecializationFilter = false});

  @override
  List<Object?> get props => [resetSpecializationFilter];
}

class DoctorSearchChanged extends DoctorListEvent {
  final String query;

  const DoctorSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class DoctorSpecializationFilterChanged extends DoctorListEvent {
  final String? specializationId;

  const DoctorSpecializationFilterChanged(this.specializationId);

  @override
  List<Object?> get props => [specializationId];
}

/// Carries the filter sheet's full submitted selection — a null field means
/// that filter is cleared, not "leave unchanged".
class DoctorFiltersChanged extends DoctorListEvent {
  final double? minRating;
  final bool? availableOnly;
  final int? maxFee;

  const DoctorFiltersChanged({
    this.minRating,
    this.availableOnly,
    this.maxFee,
  });

  @override
  List<Object?> get props => [minRating, availableOnly, maxFee];
}
