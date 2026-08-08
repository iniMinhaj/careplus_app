import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/specialization.dart';

class SpecializationChip extends StatelessWidget {
  final Specialization specialization;
  final bool selected;
  final VoidCallback onTap;

  const SpecializationChip({
    super.key,
    required this.specialization,
    required this.selected,
    required this.onTap,
  });

  static const Map<String, IconData> _iconMap = {
    'heart_pulse': Icons.favorite,
    'skin': Icons.face_retouching_natural,
    'brain': Icons.psychology,
    'baby': Icons.child_care,
    'bone': Icons.accessibility_new,
    'female': Icons.pregnant_woman,
    'tooth': Icons.medical_services,
    'mind': Icons.self_improvement,
    'stethoscope': Icons.health_and_safety,
    'ear': Icons.hearing,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[specialization.icon] ?? Icons.local_hospital;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              specialization.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
