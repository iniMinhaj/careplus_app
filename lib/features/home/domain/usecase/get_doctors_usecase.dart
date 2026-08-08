import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entity/doctor.dart';
import '../repository/home_repository.dart';

class GetDoctorsUsecase implements UseCase<List<Doctor>, GetDoctorsParams> {
  final HomeRepository _repository;

  GetDoctorsUsecase({required HomeRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<Doctor>>> call(GetDoctorsParams params) async {
    return await _repository.getDoctors(
      query: params.query,
      specializationId: params.specializationId,
      minRating: params.minRating,
      availableOnly: params.availableOnly,
      maxFee: params.maxFee,
    );
  }
}

class GetDoctorsParams extends Equatable {
  final String query;
  final String? specializationId;
  final double? minRating;
  final bool? availableOnly;
  final int? maxFee;

  const GetDoctorsParams({
    this.query = '',
    this.specializationId,
    this.minRating,
    this.availableOnly,
    this.maxFee,
  });

  @override
  List<Object?> get props =>
      [query, specializationId, minRating, availableOnly, maxFee];
}
