import 'package:equatable/equatable.dart';

sealed class DoctorDetailEvent extends Equatable {
  const DoctorDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the doctor detail screen is opened, to load the doctor by id.
class DoctorDetailRequested extends DoctorDetailEvent {
  final String doctorId;

  const DoctorDetailRequested(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}

/// Fired when the user taps an available date on the slot calendar.
/// Clears any previously selected time slot.
class DoctorDateSelected extends DoctorDetailEvent {
  final String date;

  const DoctorDateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

/// Fired when the user taps a time slot chip for the selected date.
class DoctorSlotSelected extends DoctorDetailEvent {
  final String slot;

  const DoctorSlotSelected(this.slot);

  @override
  List<Object?> get props => [slot];
}
