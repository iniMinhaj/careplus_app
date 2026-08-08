import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../../core/network/mock_api_client.dart';
import '../../models/health_record_model.dart';

abstract interface class HealthRecordsRemoteDataSource {
  Future<List<HealthRecordModel>> getRecords();

  /// [filePath] is the path of the file picked by the user (e.g. from a
  /// transient file-picker cache location). The implementation copies it
  /// into a permanent app-owned location before persisting the record.
  Future<HealthRecordModel> uploadRecord({
    required String title,
    required String type,
    required String filePath,
    required String fileType,
    String? notes,
  });
}

class HealthRecordsRemoteDataSourceImpl implements HealthRecordsRemoteDataSource {
  static const String _fileName = 'health_records.json';

  final MockApiClient _apiClient;

  HealthRecordsRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<HealthRecordModel>> getRecords() async {
    final response = await _apiClient.load(_fileName);
    final records =
        (response['health_records'] as List).cast<Map<String, dynamic>>();
    return records.map(HealthRecordModel.fromJson).toList();
  }

  @override
  Future<HealthRecordModel> uploadRecord({
    required String title,
    required String type,
    required String filePath,
    required String fileType,
    String? notes,
  }) async {
    final permanentPath = await _copyToPermanentLocation(filePath);

    final response = await _apiClient.load(_fileName);
    final records =
        (response['health_records'] as List).cast<Map<String, dynamic>>();

    final json = <String, dynamic>{
      'id': 'rec_${DateTime.now().millisecondsSinceEpoch}',
      'patientId': 'usr_001',
      'title': title,
      'type': type,
      'relatedDoctorId': null,
      'relatedDoctorName': null,
      'relatedAppointmentId': null,
      'fileUrl': permanentPath,
      'fileType': fileType,
      'date': DateTime.now().toIso8601String().split('T').first,
      'notes': notes ?? '',
    };

    await _apiClient.save(_fileName, {
      ...response,
      'health_records': [json, ...records],
    });

    return HealthRecordModel.fromJson(json);
  }

  /// Copies the picked file (which may live in a transient cache directory
  /// managed by the OS/file picker) into `<app documents dir>/health_records/`
  /// so it survives independently of the picker's temp storage.
  Future<String> _copyToPermanentLocation(String pickedFilePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${docsDir.path}/health_records');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final originalFile = File(pickedFilePath);
    final originalName = pickedFilePath.split(Platform.pathSeparator).last;
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final targetPath = '${targetDir.path}/$uniqueName';

    final copied = await originalFile.copy(targetPath);
    return copied.path;
  }
}
