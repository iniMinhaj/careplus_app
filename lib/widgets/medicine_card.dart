import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/theme/app_theme.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final void Function(String time)? onMarkTaken;

  const MedicineCard({super.key, required this.medicine, this.onMarkTaken});

  bool _takenToday(String time) {
    final today = DateTime.now().toIso8601String().split('T').first;
    return medicine.adherenceLog
        .any((l) => l.date == today && l.time == time && l.taken);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicine.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(
                        '${medicine.dosage} · ${medicine.frequency.replaceAll('_', ' ')}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (!medicine.isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Ended', style: TextStyle(fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(medicine.instructions,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          if (medicine.isActive) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: medicine.reminderTimes.map((time) {
                final taken = _takenToday(time);
                return ActionChip(
                  onPressed: taken ? null : () => onMarkTaken?.call(time),
                  avatar: Icon(
                    taken ? Icons.check_circle : Icons.access_time,
                    size: 16,
                    color: taken ? AppColors.secondary : AppColors.primary,
                  ),
                  label: Text(time, style: const TextStyle(fontSize: 12)),
                  backgroundColor: taken
                      ? AppColors.secondary.withOpacity(0.08)
                      : AppColors.primary.withOpacity(0.06),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
