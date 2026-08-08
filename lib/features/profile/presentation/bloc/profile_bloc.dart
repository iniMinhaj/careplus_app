import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/get_profile_usecase.dart';
import '../../domain/usecase/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase _getProfileUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;

  ProfileBloc({
    required GetProfileUsecase getProfileUsecase,
    required UpdateProfileUsecase updateProfileUsecase,
  })  : _getProfileUsecase = getProfileUsecase,
        _updateProfileUsecase = updateProfileUsecase,
        super(const ProfileState.initial()) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    final result = await _getProfileUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (user) => emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _updateProfileUsecase(UpdateProfileParams(
      userId: currentUser.id,
      name: event.name,
      phone: event.phone,
      bloodGroup: event.bloodGroup,
      address: event.address,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        errorMessage: failure.userMessage,
      )),
      (user) => emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
        isSubmitting: false,
        clearError: true,
      )),
    );
  }
}
