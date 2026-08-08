import '../../../../../core/network/mock_api_client.dart';
import '../../models/doctor_model.dart';
import '../../models/specialization_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<SpecializationModel>> getSpecializations();

  Future<List<DoctorModel>> getDoctors({
    String query = '',
    String? specializationId,
    double? minRating,
    bool? availableOnly,
    int? maxFee,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final MockApiClient _apiClient;

  HomeRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<SpecializationModel>> getSpecializations() async {
    final response = await _apiClient.load('specializations.json');
    return (response['specializations'] as List)
        .map((e) => SpecializationModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<DoctorModel>> getDoctors({
    String query = '',
    String? specializationId,
    double? minRating,
    bool? availableOnly,
    int? maxFee,
  }) async {
    final response = await _apiClient.load('doctors.json');
    var doctors =
        (response['doctors'] as List).map((e) => DoctorModel.fromJson(e)).toList();

    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      doctors = doctors
          .where((d) =>
              d.name.toLowerCase().contains(trimmedQuery) ||
              d.specializationName.toLowerCase().contains(trimmedQuery) ||
              d.hospital.toLowerCase().contains(trimmedQuery))
          .toList();
    }

    if (specializationId != null) {
      doctors =
          doctors.where((d) => d.specializationId == specializationId).toList();
    }

    if (minRating != null) {
      doctors = doctors.where((d) => d.rating >= minRating).toList();
    }

    if (availableOnly == true) {
      doctors = doctors.where((d) => d.isAvailableToday).toList();
    }

    if (maxFee != null) {
      doctors = doctors.where((d) => d.consultationFee <= maxFee).toList();
    }

    return doctors;
  }
}
