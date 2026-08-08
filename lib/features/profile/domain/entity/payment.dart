import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String appointmentId;
  final int amount;
  final String currency;
  final String method;
  final String status;
  final String transactionId;
  final String paidAt;
  final String? refundedAt;

  const Payment({
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

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        amount,
        currency,
        method,
        status,
        transactionId,
        paidAt,
        refundedAt,
      ];
}
