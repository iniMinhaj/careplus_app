import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingPaymentScreen extends StatelessWidget {
  const BookingPaymentScreen({super.key});

  static const _methods = [
    {
      'id': 'bkash',
      'name': 'bKash',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'nagad',
      'name': 'Nagad',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state.status == BookingStatus.success) {
            context.pushReplacement(
              AppRoutes.bookingSuccess,
              extra: context.read<BookingBloc>(),
            );
          } else if (state.status == BookingStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Payment could not be processed')),
            );
          }
        },
        builder: (context, state) {
          final isProcessing = state.status == BookingStatus.submitting;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Payment Method',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                ..._methods.map((m) {
                  final selected = state.paymentMethod == m['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => context
                          .read<BookingBloc>()
                          .add(PaymentMethodChanged(m['id'] as String)),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.5 : 1),
                        ),
                        child: Row(
                          children: [
                            Icon(m['icon'] as IconData,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(m['name'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600))),
                            Radio<String>(
                              value: m['id'] as String,
                              groupValue: state.paymentMethod,
                              onChanged: (v) => context
                                  .read<BookingBloc>()
                                  .add(PaymentMethodChanged(v!)),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payable',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('৳${state.totalFee}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () => context
                          .read<BookingBloc>()
                          .add(const PaymentSubmitted()),
                  child: isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text('Pay ৳${state.totalFee}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
