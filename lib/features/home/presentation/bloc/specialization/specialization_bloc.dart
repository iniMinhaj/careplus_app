import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecase/get_specializations_usecase.dart';
import 'specialization_event.dart';
import 'specialization_state.dart';

class SpecializationBloc
    extends Bloc<SpecializationEvent, SpecializationState> {
  final GetSpecializationsUsecase _getSpecializationsUsecase;

  SpecializationBloc({
    required GetSpecializationsUsecase getSpecializationsUsecase,
  })  : _getSpecializationsUsecase = getSpecializationsUsecase,
        super(const SpecializationState.initial()) {
    on<SpecializationRequested>(_onRequested);
    on<SpecializationSelected>(_onSelected);
  }

  Future<void> _onRequested(
    SpecializationRequested event,
    Emitter<SpecializationState> emit,
  ) async {
    emit(state.copyWith(
      status: SpecializationStatus.loading,
      clearError: true,
      clearSelection: event.resetSelection,
    ));
    final result = await _getSpecializationsUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: SpecializationStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (specializations) => emit(state.copyWith(
        status: SpecializationStatus.success,
        specializations: specializations,
        clearError: true,
      )),
    );
  }

  void _onSelected(
    SpecializationSelected event,
    Emitter<SpecializationState> emit,
  ) {
    final isSameSelection = state.selectedId == event.id;
    emit(state.copyWith(
      selectedId: isSameSelection ? null : event.id,
      clearSelection: isSameSelection,
    ));
  }
}
