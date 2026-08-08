import 'package:equatable/equatable.dart';

import '../../../domain/entity/specialization.dart';

enum SpecializationStatus { initial, loading, success, failure }

class SpecializationState extends Equatable {
  final SpecializationStatus status;
  final List<Specialization> specializations;
  final String? selectedId;
  final String? errorMessage;

  const SpecializationState({
    this.status = SpecializationStatus.initial,
    this.specializations = const [],
    this.selectedId,
    this.errorMessage,
  });

  const SpecializationState.initial() : this();

  SpecializationState copyWith({
    SpecializationStatus? status,
    List<Specialization>? specializations,
    String? selectedId,
    bool clearSelection = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SpecializationState(
      status: status ?? this.status,
      specializations: specializations ?? this.specializations,
      selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, specializations, selectedId, errorMessage];
}
