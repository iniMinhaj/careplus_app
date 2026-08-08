import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/get_payments_usecase.dart';
import 'payment_history_event.dart';
import 'payment_history_state.dart';

class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final GetPaymentsUsecase _getPaymentsUsecase;

  PaymentHistoryBloc({required GetPaymentsUsecase getPaymentsUsecase})
      : _getPaymentsUsecase = getPaymentsUsecase,
        super(const PaymentHistoryState.initial()) {
    on<PaymentHistoryRequested>(_onPaymentHistoryRequested);
  }

  Future<void> _onPaymentHistoryRequested(
    PaymentHistoryRequested event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    emit(state.copyWith(
        status: PaymentHistoryStatus.loading, clearError: true));
    final result = await _getPaymentsUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: PaymentHistoryStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (payments) => emit(state.copyWith(
        status: PaymentHistoryStatus.success,
        payments: payments,
        clearError: true,
      )),
    );
  }
}
