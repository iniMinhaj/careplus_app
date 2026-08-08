import 'package:equatable/equatable.dart';

sealed class PaymentHistoryEvent extends Equatable {
  const PaymentHistoryEvent();

  @override
  List<Object?> get props => [];
}

class PaymentHistoryRequested extends PaymentHistoryEvent {
  const PaymentHistoryRequested();
}
