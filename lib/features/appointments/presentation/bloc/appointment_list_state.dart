import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:equatable/equatable.dart';

enum AppointmentListStatus { initial, loading, success, failure }

class AppointmentListState extends Equatable {
  final AppointmentListStatus status;
  final List<Appointment> appointments;
  final String? errorMessage;

  /// Bumped every time a cancel completes successfully. It has no bearing on
  /// what's rendered — the UI listens for a change in this counter (not its
  /// value) to fire a one-off "Appointment cancelled" SnackBar, since the
  /// list itself gets refreshed via a normal AppointmentListRequested refetch
  /// and would otherwise look identical to any other successful load.
  final int cancelledTick;

  const AppointmentListState({
    this.status = AppointmentListStatus.initial,
    this.appointments = const [],
    this.errorMessage,
    this.cancelledTick = 0,
  });

  const AppointmentListState.initial() : this();

  /// Status `upcoming` or `ongoing`, soonest first.
  List<Appointment> get upcoming {
    final items = appointments
        .where((a) => a.status == 'upcoming' || a.status == 'ongoing')
        .toList()
      ..sort((a, b) => _dateTimeOf(a).compareTo(_dateTimeOf(b)));
    return items;
  }

  /// Status `completed` or `cancelled`, most recent first.
  List<Appointment> get past {
    final items = appointments
        .where((a) => a.status == 'completed' || a.status == 'cancelled')
        .toList()
      ..sort((a, b) => _dateTimeOf(b).compareTo(_dateTimeOf(a)));
    return items;
  }

  AppointmentListState copyWith({
    AppointmentListStatus? status,
    List<Appointment>? appointments,
    String? errorMessage,
    bool clearError = false,
    int? cancelledTick,
  }) {
    return AppointmentListState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cancelledTick: cancelledTick ?? this.cancelledTick,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointments,
        errorMessage,
        cancelledTick,
      ];
}

/// Combines the `yyyy-MM-dd` date with the `hh:mm AM/PM` time into a
/// sortable DateTime. Falls back to the epoch on anything unparsable so a
/// malformed row sorts to the back rather than throwing.
DateTime _dateTimeOf(Appointment appointment) {
  try {
    final dateParts = appointment.date.split('-').map(int.parse).toList();
    var hour = 0;
    var minute = 0;
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(appointment.time.trim());
    if (match != null) {
      hour = int.parse(match.group(1)!);
      minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
    }
    return DateTime(dateParts[0], dateParts[1], dateParts[2], hour, minute);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
