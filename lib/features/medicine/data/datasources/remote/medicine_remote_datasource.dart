import '../../../../../core/network/mock_api_client.dart';
import '../../models/medicine_model.dart';

abstract interface class MedicineRemoteDataSource {
  Future<List<MedicineModel>> getMedicines();

  Future<MedicineModel> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required String instructions,
  });

  Future<void> markTaken({
    required String medicineId,
    required String time,
  });
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final MockApiClient _apiClient;

  MedicineRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<MedicineModel>> getMedicines() async {
    final response = await _apiClient.load('medicines.json');
    final medicines =
        (response['medicines'] as List).cast<Map<String, dynamic>>();
    return medicines.map((e) => MedicineModel.fromJson(e)).toList();
  }

  @override
  Future<MedicineModel> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required String instructions,
  }) async {
    final response = await _apiClient.load('medicines.json');
    final medicines =
        (response['medicines'] as List).cast<Map<String, dynamic>>();

    final now = DateTime.now();
    final startDate = now.toIso8601String().split('T').first;
    final endDate =
        now.add(const Duration(days: 7)).toIso8601String().split('T').first;

    final json = <String, dynamic>{
      'id': 'med_${now.millisecondsSinceEpoch}',
      'patientId': 'usr_001',
      'name': name,
      'dosage': dosage,
      'form': 'tablet',
      'frequency': frequency,
      'reminderTimes': reminderTimes,
      'startDate': startDate,
      'endDate': endDate,
      'instructions': instructions,
      'isActive': true,
      'adherenceLog': <Map<String, dynamic>>[],
    };

    await _apiClient.save('medicines.json', {
      ...response,
      'medicines': [json, ...medicines],
    });

    return MedicineModel.fromJson(json);
  }

  @override
  Future<void> markTaken({
    required String medicineId,
    required String time,
  }) async {
    final response = await _apiClient.load('medicines.json');
    final medicines =
        (response['medicines'] as List).cast<Map<String, dynamic>>();

    final today = DateTime.now().toIso8601String().split('T').first;

    final updated = medicines.map((m) {
      if (m['id'] != medicineId) return m;
      final adherenceLog =
          (m['adherenceLog'] as List? ?? []).cast<Map<String, dynamic>>();
      return {
        ...m,
        'adherenceLog': [
          ...adherenceLog,
          {'date': today, 'time': time, 'taken': true},
        ],
      };
    }).toList();

    await _apiClient.save('medicines.json', {
      ...response,
      'medicines': updated,
    });
  }
}
