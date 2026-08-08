import 'package:equatable/equatable.dart';

sealed class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load and pull-to-refresh both use this event.
class MedicineListRequested extends MedicineEvent {
  const MedicineListRequested();
}

class MedicineAddRequested extends MedicineEvent {
  final String name;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes;
  final String instructions;

  const MedicineAddRequested({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.reminderTimes,
    required this.instructions,
  });

  @override
  List<Object?> get props =>
      [name, dosage, frequency, reminderTimes, instructions];
}

class MedicineMarkTakenRequested extends MedicineEvent {
  final String medicineId;
  final String time;

  const MedicineMarkTakenRequested({
    required this.medicineId,
    required this.time,
  });

  @override
  List<Object?> get props => [medicineId, time];
}
