import 'package:equatable/equatable.dart';

import '../../domain/entity/medicine.dart';

enum MedicineListStatus { initial, loading, success, empty, failure }

class MedicineState extends Equatable {
  final MedicineListStatus status;
  final List<Medicine> medicines;
  final bool isAdding;
  final bool isMarking;
  final String? errorMessage;

  const MedicineState({
    this.status = MedicineListStatus.initial,
    this.medicines = const [],
    this.isAdding = false,
    this.isMarking = false,
    this.errorMessage,
  });

  const MedicineState.initial() : this();

  /// Percentage of today's reminder slots, across active medicines, that
  /// have already been marked taken today. Mirrors the legacy screen's
  /// `_adherencePercent` getter.
  int get adherencePercentToday {
    final today = DateTime.now().toIso8601String().split('T').first;
    int total = 0;
    int taken = 0;
    for (final med in medicines.where((m) => m.isActive)) {
      total += med.reminderTimes.length;
      taken +=
          med.adherenceLog.where((l) => l.date == today && l.taken).length;
    }
    if (total == 0) return 0;
    return ((taken / total) * 100).clamp(0, 100).round();
  }

  MedicineState copyWith({
    MedicineListStatus? status,
    List<Medicine>? medicines,
    bool? isAdding,
    bool? isMarking,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MedicineState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      isAdding: isAdding ?? this.isAdding,
      isMarking: isMarking ?? this.isMarking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, medicines, isAdding, isMarking, errorMessage];
}
