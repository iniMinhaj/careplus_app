import 'package:flutter/material.dart';
import '../core/theme/app_color.dart';
import '../models/models.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onTap,
  });

  Color _statusColor() {
    switch (appointment.status) {
      case 'upcoming':
        return AppColors.primary;
      case 'completed':
        return AppColors.secondary;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _consultationIcon() {
    switch (appointment.consultationType) {
      case 'video':
        return Icons.videocam_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.local_hospital_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    appointment.doctorPhotoUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.border,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.doctorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(appointment.specializationName,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: TextStyle(
                        color: _statusColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('${appointment.date} · ${appointment.time}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 14),
                Icon(_consultationIcon(),
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(appointment.consultationType,
                    style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text('৳${appointment.fee}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            if (appointment.status == 'upcoming' && onCancel != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Cancel Appointment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
