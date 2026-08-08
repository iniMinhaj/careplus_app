import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/debounce_event_transformer.dart';
import '../../../domain/usecase/get_doctors_usecase.dart';
import 'doctor_list_event.dart';
import 'doctor_list_state.dart';

class DoctorListBloc extends Bloc<DoctorListEvent, DoctorListState> {
  final GetDoctorsUsecase _getDoctorsUsecase;

  /// Monotonic guard: a slow, superseded request (e.g. a debounced search
  /// that resolves after a subsequent filter change) must not overwrite
  /// newer state when it finally completes.
  int _requestId = 0;

  DoctorListBloc({required GetDoctorsUsecase getDoctorsUsecase})
      : _getDoctorsUsecase = getDoctorsUsecase,
        super(const DoctorListState.initial()) {
    on<DoctorListRequested>(_onListRequested);
    on<DoctorSearchChanged>(
      _onSearchChanged,
      transformer: debounce(const Duration(milliseconds: 450)),
    );
    on<DoctorSpecializationFilterChanged>(_onSpecializationFilterChanged);
    on<DoctorFiltersChanged>(_onFiltersChanged);
  }

  Future<void> _onListRequested(
    DoctorListRequested event,
    Emitter<DoctorListState> emit,
  ) async {
    await _fetch(emit, clearSpecializationId: event.resetSpecializationFilter);
  }

  Future<void> _onSearchChanged(
    DoctorSearchChanged event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await _fetch(emit);
  }

  Future<void> _onSpecializationFilterChanged(
    DoctorSpecializationFilterChanged event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(state.copyWith(
      specializationId: event.specializationId,
      clearSpecializationId: event.specializationId == null,
    ));
    await _fetch(emit);
  }

  Future<void> _onFiltersChanged(
    DoctorFiltersChanged event,
    Emitter<DoctorListState> emit,
  ) async {
    emit(state.copyWith(
      minRating: event.minRating,
      clearMinRating: event.minRating == null,
      availableOnly: event.availableOnly,
      clearAvailableOnly: event.availableOnly == null,
      maxFee: event.maxFee,
      clearMaxFee: event.maxFee == null,
    ));
    await _fetch(emit);
  }

  Future<void> _fetch(
    Emitter<DoctorListState> emit, {
    bool clearSpecializationId = false,
  }) async {
    final requestId = ++_requestId;
    emit(state.copyWith(
      status: DoctorListStatus.loading,
      clearError: true,
      clearSpecializationId: clearSpecializationId,
    ));
    final result = await _getDoctorsUsecase(GetDoctorsParams(
      query: state.searchQuery,
      specializationId: state.specializationId,
      minRating: state.minRating,
      availableOnly: state.availableOnly,
      maxFee: state.maxFee,
    ));
    if (requestId != _requestId) return;
    result.fold(
      (failure) => emit(state.copyWith(
        status: DoctorListStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (doctors) => emit(state.copyWith(
        status:
            doctors.isEmpty ? DoctorListStatus.empty : DoctorListStatus.success,
        doctors: doctors,
        clearError: true,
      )),
    );
  }
}
