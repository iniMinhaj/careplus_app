import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entity/medicine.dart';
import '../../domain/usecase/add_medicine_usecase.dart';
import '../../domain/usecase/get_medicines_usecase.dart';
import '../../domain/usecase/mark_medicine_taken_usecase.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final GetMedicinesUsecase _getMedicinesUsecase;
  final AddMedicineUsecase _addMedicineUsecase;
  final MarkMedicineTakenUsecase _markMedicineTakenUsecase;
  final NotificationService _notificationService;

  MedicineBloc({
    required GetMedicinesUsecase getMedicinesUsecase,
    required AddMedicineUsecase addMedicineUsecase,
    required MarkMedicineTakenUsecase markMedicineTakenUsecase,
    required NotificationService notificationService,
  })  : _getMedicinesUsecase = getMedicinesUsecase,
        _addMedicineUsecase = addMedicineUsecase,
        _markMedicineTakenUsecase = markMedicineTakenUsecase,
        _notificationService = notificationService,
        super(const MedicineState.initial()) {
    on<MedicineListRequested>(_onListRequested);
    on<MedicineAddRequested>(_onAddRequested);
    on<MedicineMarkTakenRequested>(_onMarkTakenRequested);
  }

  Future<void> _onListRequested(
    MedicineListRequested event,
    Emitter<MedicineState> emit,
  ) async {
    emit(state.copyWith(status: MedicineListStatus.loading, clearError: true));
    await _fetch(emit);
  }

  Future<void> _onAddRequested(
    MedicineAddRequested event,
    Emitter<MedicineState> emit,
  ) async {
    emit(state.copyWith(isAdding: true, clearError: true));
    final result = await _addMedicineUsecase(AddMedicineParams(
      name: event.name,
      dosage: event.dosage,
      frequency: event.frequency,
      reminderTimes: event.reminderTimes,
      instructions: event.instructions,
    ));
    await result.fold(
      (failure) async {
        emit(state.copyWith(
            isAdding: false, errorMessage: failure.userMessage));
      },
      (medicine) async {
        await _scheduleReminders(medicine);
        await _fetch(emit);
        emit(state.copyWith(isAdding: false));
      },
    );
  }

  Future<void> _onMarkTakenRequested(
    MedicineMarkTakenRequested event,
    Emitter<MedicineState> emit,
  ) async {
    emit(state.copyWith(isMarking: true, clearError: true));
    final result = await _markMedicineTakenUsecase(MarkMedicineTakenParams(
      medicineId: event.medicineId,
      time: event.time,
    ));
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(
          state.copyWith(isMarking: false, errorMessage: failure.userMessage));
      return;
    }
    await _fetch(emit);
    emit(state.copyWith(isMarking: false));
  }

  Future<void> _fetch(Emitter<MedicineState> emit) async {
    final result = await _getMedicinesUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: MedicineListStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (medicines) => emit(state.copyWith(
        status: medicines.isEmpty
            ? MedicineListStatus.empty
            : MedicineListStatus.success,
        medicines: medicines,
        clearError: true,
      )),
    );
  }

  Future<void> _scheduleReminders(Medicine medicine) async {
    for (var i = 0; i < medicine.reminderTimes.length; i++) {
      final parsed = _parseTime(medicine.reminderTimes[i]);
      if (parsed == null) continue;
      await _notificationService.scheduleDailyReminder(
        id: NotificationService.reminderNotificationId(medicine.id, i),
        title: 'Time to take ${medicine.name}',
        body: '${medicine.dosage} · ${medicine.reminderTimes[i]}',
        hour: parsed.$1,
        minute: parsed.$2,
      );
    }
  }

  /// Parses a `"08:00 AM"` / `"08:00 PM"` style string into 24-hour
  /// (hour, minute), mindful of the 12 AM (-> 0) / 12 PM (-> 12) edge cases.
  /// Returns null if the string can't be parsed.
  (int, int)? _parseTime(String value) {
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
            .firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();
    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }
    return (hour, minute);
  }
}
