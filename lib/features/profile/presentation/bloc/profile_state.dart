import 'package:equatable/equatable.dart';

import '../../../auth/domain/entity/user.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  failure,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;

  /// Tracks the in-flight "edit profile" submission separately from
  /// [status] (which reflects the initial profile load) so the profile
  /// screen's status branches aren't disturbed by an edit made after the
  /// profile has already loaded successfully.
  final bool isSubmitting;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.isSubmitting = false,
  });

  const ProfileState.initial() : this();

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isSubmitting];
}
