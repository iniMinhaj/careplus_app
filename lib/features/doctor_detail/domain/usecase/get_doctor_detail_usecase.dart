import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/doctor_detail.dart';
import '../repository/doctor_detail_repository.dart';

class GetDoctorDetailUsecase
    implements UseCase<DoctorDetail, GetDoctorDetailParams> {
  final DoctorDetailRepository _repository;

  GetDoctorDetailUsecase({required DoctorDetailRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, DoctorDetail>> call(
    GetDoctorDetailParams params,
  ) async {
    return await _repository.getDoctorById(params.doctorId);
  }
}

class GetDoctorDetailParams extends Equatable {
  final String doctorId;

  const GetDoctorDetailParams({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}
