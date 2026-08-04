import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase _getProfileUsecase;

  ProfileBloc({required GetProfileUsecase getProfileUsecase})
      : _getProfileUsecase = getProfileUsecase,
        super(const ProfileState.initial()) {
    on<ProfileRequested>(_onProfileRequested);
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
}
