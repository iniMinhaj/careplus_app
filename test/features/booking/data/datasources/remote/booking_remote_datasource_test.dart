import 'package:careplus/core/network/mock_api_client.dart';
import 'package:careplus/features/booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMockApiClient extends Mock implements MockApiClient {}

void main() {
  late MockMockApiClient mockApiClient;
  late BookingRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockApiClient = MockMockApiClient();
    dataSource = BookingRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  test(
      'reads appointments.json, saves the new entry prepended to the existing list, '
      'and returns it mapped to a model', () async {
    when(() => mockApiClient.load('appointments.json', latencyMs: 900))
        .thenAnswer((_) async => {
              'appointments': [
                {'id': 'appt_existing'},
              ],
            });
    when(() => mockApiClient.save('appointments.json', any()))
        .thenAnswer((_) async {});

    final result = await dataSource.bookAppointment(
      doctorId: 'doc_01',
      doctorName: 'Dr. Anika Rahman',
      doctorPhotoUrl: '',
      specializationName: 'Cardiologist',
      date: '2026-08-10',
      time: '10:00 AM',
      fee: 1000,
      currency: 'BDT',
      consultationType: 'video',
      reasonForVisit: 'Routine checkup',
      paymentMethod: 'bkash',
    );

    expect(result.doctorName, 'Dr. Anika Rahman');
    expect(result.status, 'upcoming');
    expect(result.paymentStatus, 'paid');

    final captured =
        verify(() => mockApiClient.save('appointments.json', captureAny()))
            .captured;
    final saved = captured.single as Map<String, dynamic>;
    final savedAppointments = saved['appointments'] as List;
    expect(savedAppointments.length, 2);
    expect((savedAppointments.first as Map)['doctorId'], 'doc_01');
    expect((savedAppointments.last as Map)['id'], 'appt_existing');
  });
}
