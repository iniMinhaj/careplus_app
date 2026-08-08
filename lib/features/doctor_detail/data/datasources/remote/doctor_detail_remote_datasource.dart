import '../../../../../core/network/mock_api_client.dart';
import '../../models/doctor_detail_model.dart';

abstract interface class DoctorDetailRemoteDataSource {
  Future<DoctorDetailModel> getDoctorById(String id);
}

class DoctorDetailRemoteDataSourceImpl implements DoctorDetailRemoteDataSource {
  final MockApiClient _apiClient;

  DoctorDetailRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<DoctorDetailModel> getDoctorById(String id) async {
    final response = await _apiClient.load('doctors.json');
    final doctors = (response['doctors'] as List).cast<Map<String, dynamic>>();

    final json = doctors.firstWhere(
      (d) => d['id'] == id,
      orElse: () => throw Exception('Doctor not found'),
    );

    return DoctorDetailModel.fromJson(json);
  }
}
