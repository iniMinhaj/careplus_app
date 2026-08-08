import 'package:equatable/equatable.dart';

import '../../domain/entity/payment.dart';

enum PaymentHistoryStatus {
  initial,
  loading,
  success,
  failure,
}

class PaymentHistoryState extends Equatable {
  final PaymentHistoryStatus status;
  final List<Payment> payments;
  final String? errorMessage;

  const PaymentHistoryState({
    this.status = PaymentHistoryStatus.initial,
    this.payments = const [],
    this.errorMessage,
  });

  const PaymentHistoryState.initial() : this();

  PaymentHistoryState copyWith({
    PaymentHistoryStatus? status,
    List<Payment>? payments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentHistoryState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, payments, errorMessage];
}
