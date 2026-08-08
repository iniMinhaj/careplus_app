import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entity/user.dart';
import '../../../auth/domain/repository/auth_repo.dart';

class UpdateProfileUsecase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository _authRepository;

  UpdateProfileUsecase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await _authRepository.updateProfile(
      userId: params.userId,
      name: params.name,
      phone: params.phone,
      bloodGroup: params.bloodGroup,
      address: params.address,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String name;
  final String phone;
  final String bloodGroup;
  final String address;

  const UpdateProfileParams({
    required this.userId,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.address,
  });

  @override
  List<Object?> get props => [userId, name, phone, bloodGroup, address];
}
