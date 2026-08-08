import 'package:equatable/equatable.dart';

import '../../domain/entity/doctor_detail.dart';

enum DoctorDetailStatus { initial, loading, success, failure }

class DoctorDetailState extends Equatable {
  final DoctorDetailStatus status;
  final DoctorDetail? doctorDetail;
  final String? selectedDate;
  final String? selectedSlot;
  final String? errorMessage;

  const DoctorDetailState({
    this.status = DoctorDetailStatus.initial,
    this.doctorDetail,
    this.selectedDate,
    this.selectedSlot,
    this.errorMessage,
  });

  DoctorDetailState copyWith({
    DoctorDetailStatus? status,
    DoctorDetail? doctorDetail,
    String? selectedDate,
    String? selectedSlot,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedSlot = false,
  }) {
    return DoctorDetailState(
      status: status ?? this.status,
      doctorDetail: doctorDetail ?? this.doctorDetail,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot:
          clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        doctorDetail,
        selectedDate,
        selectedSlot,
        errorMessage,
      ];
}
