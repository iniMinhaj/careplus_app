import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/theme/app_theme.dart';

class RecordDetailScreen extends StatelessWidget {
  final HealthRecordModel record;
  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(record.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      record.fileType == 'pdf'
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    Text('${record.fileType.toUpperCase()} preview',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _detailRow('Type', record.type.replaceAll('_', ' ')),
            _detailRow('Date', record.date),
            if (record.relatedDoctorName != null)
              _detailRow('Doctor', record.relatedDoctorName!),
            const SizedBox(height: 12),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(record.notes,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
