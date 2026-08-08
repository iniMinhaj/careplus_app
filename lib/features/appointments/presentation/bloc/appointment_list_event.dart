import 'package:equatable/equatable.dart';

sealed class AppointmentListEvent extends Equatable {
  const AppointmentListEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load and pull-to-refresh both use this event.
class AppointmentListRequested extends AppointmentListEvent {
  const AppointmentListRequested();
}

class AppointmentCancelRequested extends AppointmentListEvent {
  final String appointmentId;

  const AppointmentCancelRequested(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
