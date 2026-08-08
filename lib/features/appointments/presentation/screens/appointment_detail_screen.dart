import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import 'join_call_placeholder_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  Color get _statusColor {
    switch (appointment.status) {
      case 'upcoming':
      case 'ongoing':
        return AppColors.primary;
      case 'completed':
        return AppColors.secondary;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _consultationIcon {
    switch (appointment.consultationType) {
      case 'video':
        return Icons.videocam_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  bool get _canJoinCall =>
      appointment.consultationType == 'video' &&
      (appointment.status == 'upcoming' || appointment.status == 'ongoing');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorHeaderCard(
              appointment: appointment,
              statusColor: _statusColor,
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Appointment info',
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date & time',
                  value: '${appointment.date} · ${appointment.time}',
                ),
                _InfoRow(
                  icon: _consultationIcon,
                  label: 'Consultation type',
                  value: _titleCase(appointment.consultationType),
                ),
                _InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Reason for visit',
                  value: appointment.reasonForVisit.isEmpty
                      ? '—'
                      : appointment.reasonForVisit,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Payment',
              children: [
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Fee',
                  value: '৳${appointment.fee} ${appointment.currency}',
                ),
                _InfoRow(
                  icon: Icons.verified_outlined,
                  label: 'Payment status',
                  value: _titleCase(appointment.paymentStatus),
                ),
                _InfoRow(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment method',
                  value: _titleCase(appointment.paymentMethod),
                ),
              ],
            ),
            if (_canJoinCall) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JoinCallPlaceholderScreen(
                          doctorName: appointment.doctorName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Join Call'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return '—';
    return value
        .split(RegExp(r'[\s-]+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _DoctorHeaderCard extends StatelessWidget {
  final Appointment appointment;
  final Color statusColor;

  const _DoctorHeaderCard({
    required this.appointment,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              appointment.doctorPhotoUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: AppColors.border,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.doctorName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text(appointment.specializationName,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
