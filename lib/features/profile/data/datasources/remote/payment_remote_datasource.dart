import '../../../../../core/network/mock_api_client.dart';
import '../../models/payment_model.dart';

abstract interface class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getPayments();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final MockApiClient _apiClient;

  PaymentRemoteDataSourceImpl({required MockApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<PaymentModel>> getPayments() async {
    final response = await _apiClient.load('payments.json');
    final payments =
        (response['payments'] as List).cast<Map<String, dynamic>>();
    return payments.map(PaymentModel.fromJson).toList();
  }
}
