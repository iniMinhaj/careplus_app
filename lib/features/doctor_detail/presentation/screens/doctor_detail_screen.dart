import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/common_widgets.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/screens/booking_confirm_screen.dart';
import '../../domain/entity/doctor_detail.dart';
import '../bloc/doctor_detail_bloc.dart';
import '../bloc/doctor_detail_event.dart';
import '../bloc/doctor_detail_state.dart';
import '../widgets/slot_calendar.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorDetailBloc>()
        ..add(DoctorDetailRequested(widget.doctorId)),
      child: _DoctorDetailView(doctorId: widget.doctorId),
    );
  }
}

class _DoctorDetailView extends StatelessWidget {
  final String doctorId;

  const _DoctorDetailView({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Details')),
      body: BlocBuilder<DoctorDetailBloc, DoctorDetailState>(
        builder: (context, state) {
          switch (state.status) {
            case DoctorDetailStatus.initial:
            case DoctorDetailStatus.loading:
              return const LoadingView();
            case DoctorDetailStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Could not load doctor details',
                onRetry: () => context
                    .read<DoctorDetailBloc>()
                    .add(DoctorDetailRequested(doctorId)),
              );
            case DoctorDetailStatus.success:
              final doctor = state.doctorDetail;
              if (doctor == null) {
                return ErrorView(
                  message: 'Could not load doctor details',
                  onRetry: () => context
                      .read<DoctorDetailBloc>()
                      .add(DoctorDetailRequested(doctorId)),
                );
              }
              return _DoctorDetailBody(doctor: doctor, state: state);
          }
        },
      ),
      bottomNavigationBar: BlocBuilder<DoctorDetailBloc, DoctorDetailState>(
        builder: (context, state) {
          if (state.status != DoctorDetailStatus.success ||
              state.doctorDetail == null) {
            return const SizedBox.shrink();
          }
          final doctor = state.doctorDetail!;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: state.selectedSlot == null || state.selectedDate == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => sl<BookingBloc>()
                                ..add(BookingStarted(
                                  doctorId: doctor.id,
                                  doctorName: doctor.name,
                                  doctorPhotoUrl: doctor.photoUrl,
                                  specializationName: doctor.specializationName,
                                  consultationFee: doctor.consultationFee,
                                  currency: doctor.currency,
                                  date: state.selectedDate!,
                                  time: state.selectedSlot!,
                                )),
                              child: const BookingConfirmScreen(),
                            ),
                          ),
                        ),
                child: const Text('Continue to Book'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorDetailBody extends StatelessWidget {
  final DoctorDetail doctor;
  final DoctorDetailState state;

  const _DoctorDetailBody({required this.doctor, required this.state});

  @override
  Widget build(BuildContext context) {
    final selectedGroup = doctor.availableSlots.where(
      (g) => g.date == state.selectedDate,
    );
    final selectedSlots =
        selectedGroup.isNotEmpty ? selectedGroup.first.slots : const <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  doctor.photoUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: AppColors.border,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      doctor.specializationName,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doctor.hospital}\n${doctor.location}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                icon: Icons.star,
                value: '${doctor.rating}',
                label: '${doctor.reviewCount} reviews',
              ),
              _StatTile(
                icon: Icons.work_outline,
                value: '${doctor.experienceYears}+',
                label: 'years exp',
              ),
              _StatTile(
                icon: Icons.payments_outlined,
                value: '৳${doctor.consultationFee}',
                label: 'fee',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('About',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            doctor.bio,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text('Education',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          ...doctor.education.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Icon(Icons.school_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(e, style: const TextStyle(fontSize: 13))),
                ]),
              )),
          const SizedBox(height: 16),
          const Text('Languages',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.languages
                .map((lang) => Chip(
                      avatar: const Icon(Icons.language,
                          size: 16, color: AppColors.primary),
                      label: Text(lang, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      side: BorderSide.none,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text('Select Date',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          SlotCalendar(
            availableSlots: doctor.availableSlots,
            selectedDate: state.selectedDate,
            onDateSelected: (date) =>
                context.read<DoctorDetailBloc>().add(DoctorDateSelected(date)),
          ),
          if (state.selectedDate != null) ...[
            const SizedBox(height: 16),
            const Text('Select Time',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            if (selectedSlots.isEmpty)
              const Text(
                'No time slots for this date.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedSlots.map((slot) {
                  final selected = state.selectedSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: selected,
                    onSelected: (_) => context
                        .read<DoctorDetailBloc>()
                        .add(DoctorSlotSelected(slot)),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.textPrimary),
                  );
                }).toList(),
              ),
          ],
          const SizedBox(height: 20),
          Text('Reviews (${doctor.reviews.length})',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          if (doctor.reviews.isEmpty)
            const Text(
              'No reviews yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            ...doctor.reviews.map((review) => _ReviewCard(review: review)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final DoctorReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              Text(
                review.date,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.warning),
              const SizedBox(width: 2),
              Text('${review.rating}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
          ),
        ],
      ),
    );
  }
}
