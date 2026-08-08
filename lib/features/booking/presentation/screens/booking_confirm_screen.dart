import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          state.doctorPhotoUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 56, height: 56, color: AppColors.border),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.doctorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(state.specializationName,
                                style: const TextStyle(
                                    color: AppColors.primary, fontSize: 12)),
                            Text('${state.date} · ${state.time}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Consultation Type',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _typeOption(context, state, 'video',
                        Icons.videocam_outlined, 'Video'),
                    const SizedBox(width: 10),
                    _typeOption(context, state, 'chat',
                        Icons.chat_bubble_outline, 'Chat'),
                    const SizedBox(width: 10),
                    _typeOption(context, state, 'in-person',
                        Icons.local_hospital_outlined, 'Visit'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Reason for visit',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  onChanged: (value) => context
                      .read<BookingBloc>()
                      .add(ReasonForVisitChanged(value)),
                  decoration: const InputDecoration(
                      hintText: 'Briefly describe your symptoms or reason...'),
                ),
                const SizedBox(height: 20),
                _summaryRow('Consultation fee', '৳${state.consultationFee}'),
                _summaryRow('Platform fee', '৳$platformFeeBdt'),
                const Divider(),
                _summaryRow('Total', '৳${state.totalFee}', bold: true),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => context.push(
              AppRoutes.bookingPayment,
              extra: context.read<BookingBloc>(),
            ),
            child: const Text('Proceed to Payment'),
          ),
        ),
      ),
    );
  }

  Widget _typeOption(BuildContext context, BookingState state, String value,
      IconData icon, String label) {
    final selected = state.consultationType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<BookingBloc>().add(ConsultationTypeChanged(value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color:
                      selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}
