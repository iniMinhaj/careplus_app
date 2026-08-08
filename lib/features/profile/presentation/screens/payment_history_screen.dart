import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../widgets/common_widgets.dart';
import '../../domain/entity/payment.dart';
import '../bloc/payment_history_bloc.dart';
import '../bloc/payment_history_event.dart';
import '../bloc/payment_history_state.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.secondary;
      case 'refunded':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
        builder: (context, state) {
          if (state.status == PaymentHistoryStatus.loading ||
              state.status == PaymentHistoryStatus.initial) {
            return const LoadingView();
          }
          if (state.status == PaymentHistoryStatus.failure) {
            return ErrorView(
              message: state.errorMessage ?? 'Could not load payments',
              onRetry: () => context
                  .read<PaymentHistoryBloc>()
                  .add(const PaymentHistoryRequested()),
            );
          }
          if (state.payments.isEmpty) {
            return const EmptyView(
                message: 'No payments yet', icon: Icons.payments_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final Payment p = state.payments[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statusColor(p.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.receipt_outlined,
                          color: _statusColor(p.status)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.transactionId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(
                              '${p.method.toUpperCase()} · ${p.paidAt.split('T').first}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳${p.amount}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(p.status,
                            style: TextStyle(
                                fontSize: 11, color: _statusColor(p.status))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
