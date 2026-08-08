import '../../../../../core/network/mock_api_client.dart';
import '../../models/appointment_model.dart';

abstract interface class BookingRemoteDataSource {
  Future<AppointmentModel> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorPhotoUrl,
    required String specializationName,
    required String date,
    required String time,
    required int fee,
    required String currency,
    required String consultationType,
    required String reasonForVisit,
    required String paymentMethod,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final MockApiClient _apiClient;

  BookingRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AppointmentModel> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorPhotoUrl,
    required String specializationName,
    required String date,
    required String time,
    required int fee,
    required String currency,
    required String consultationType,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    // Dummy payment gateway — no real backend call, but the resulting
    // appointment is written through to the shared mock appointments store
    // so it shows up in the (still-legacy) Appointments tab and survives
    // a restart, same as a real booking would.
    final response = await _apiClient.load('appointments.json', latencyMs: 900);
    final appointments =
        (response['appointments'] as List).cast<Map<String, dynamic>>();

    final json = <String, dynamic>{
      'id': 'appt_${DateTime.now().millisecondsSinceEpoch}',
      'patientId': 'usr_001',
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorPhotoUrl': doctorPhotoUrl,
      'specializationName': specializationName,
      'date': date,
      'time': time,
      'status': 'upcoming',
      'fee': fee,
      'currency': currency,
      'paymentStatus': 'paid',
      'paymentMethod': paymentMethod,
      'consultationType': consultationType,
      'reasonForVisit': reasonForVisit,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    await _apiClient.save('appointments.json', {
      ...response,
      'appointments': [json, ...appointments],
    });

    return AppointmentModel.fromJson(json);
  }
}
