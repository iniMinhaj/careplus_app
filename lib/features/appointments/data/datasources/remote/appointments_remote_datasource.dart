import 'package:careplus/features/booking/data/models/appointment_model.dart';

import '../../../../../core/network/mock_api_client.dart';

abstract interface class AppointmentsRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> cancelAppointment(String id);
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final MockApiClient _apiClient;

  AppointmentsRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    final response = await _apiClient.load('appointments.json');
    return (response['appointments'] as List)
        .cast<Map<String, dynamic>>()
        .map(AppointmentModel.fromJson)
        .toList();
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id) async {
    final response = await _apiClient.load('appointments.json', latencyMs: 0);
    final appointments =
        (response['appointments'] as List).cast<Map<String, dynamic>>();

    Map<String, dynamic>? updatedJson;
    final updated = appointments.map((a) {
      if (a['id'] == id) {
        updatedJson = {
          ...a,
          'status': 'cancelled',
          'paymentStatus': 'refunded',
        };
        return updatedJson!;
      }
      return a;
    }).toList();

    if (updatedJson == null) {
      throw StateError('Appointment not found: $id');
    }

    await _apiClient.save('appointments.json', {
      ...response,
      'appointments': updated,
    }, latencyMs: 300);

    return AppointmentModel.fromJson(updatedJson!);
  }
}
