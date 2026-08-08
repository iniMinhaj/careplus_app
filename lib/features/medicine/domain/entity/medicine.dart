import 'package:equatable/equatable.dart';

class AdherenceEntry extends Equatable {
  final String date;
  final String time;
  final bool taken;

  const AdherenceEntry({
    required this.date,
    required this.time,
    required this.taken,
  });

  @override
  List<Object?> get props => [date, time, taken];
}

class Medicine extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String form;
  final String frequency;
  final List<String> reminderTimes;
  final String startDate;
  final String endDate;
  final String instructions;
  final bool isActive;
  final List<AdherenceEntry> adherenceLog;

  const Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    required this.endDate,
    required this.instructions,
    required this.isActive,
    required this.adherenceLog,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        dosage,
        form,
        frequency,
        reminderTimes,
        startDate,
        endDate,
        instructions,
        isActive,
        adherenceLog,
      ];
}
