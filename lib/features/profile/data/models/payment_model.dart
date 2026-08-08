import '../../domain/entity/payment.dart';

class PaymentModel {
  final String id;
  final String appointmentId;
  final int amount;
  final String currency;
  final String method;
  final String status;
  final String transactionId;
  final String paidAt;
  final String? refundedAt;

  const PaymentModel({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.transactionId,
    required this.paidAt,
    this.refundedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] ?? '',
        appointmentId: json['appointmentId'] ?? '',
        amount: json['amount'] ?? 0,
        currency: json['currency'] ?? 'BDT',
        method: json['method'] ?? '',
        status: json['status'] ?? 'failed',
        transactionId: json['transactionId'] ?? '',
        paidAt: json['paidAt'] ?? '',
        refundedAt: json['refundedAt'],
      );

  Payment toEntity() => Payment(
        id: id,
        appointmentId: appointmentId,
        amount: amount,
        currency: currency,
        method: method,
        status: status,
        transactionId: transactionId,
        paidAt: paidAt,
        refundedAt: refundedAt,
      );
}
