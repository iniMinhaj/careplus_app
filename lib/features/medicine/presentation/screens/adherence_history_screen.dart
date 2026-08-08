import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/common_widgets.dart';
import '../../domain/entity/medicine.dart';

/// Simple per-medicine adherence history: one `ExpansionTile` per active
/// medicine, each listing its last 14 days of `adherenceLog` entries,
/// most-recent first.
class AdherenceHistoryScreen extends StatelessWidget {
  final List<Medicine> medicines;

  const AdherenceHistoryScreen({super.key, required this.medicines});

  static const _maxDaysShown = 14;

  @override
  Widget build(BuildContext context) {
    final activeMedicines = medicines.where((m) => m.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Adherence History')),
      body: activeMedicines.isEmpty
          ? const EmptyView(
              message: 'No active medicines to show history for',
              icon: Icons.bar_chart_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activeMedicines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final medicine = activeMedicines[index];
                final entries = [...medicine.adherenceLog]
                  ..sort((a, b) => b.date.compareTo(a.date));
                final recent = entries.take(_maxDaysShown).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.medication_outlined,
                          color: AppColors.primary),
                      title: Text(medicine.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Text(
                        '${recent.where((e) => e.taken).length}/${recent.length} taken in last ${recent.length} entries',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      children: recent.isEmpty
                          ? const [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text('No adherence records yet',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ),
                            ]
                          : recent
                              .map((entry) => ListTile(
                                    dense: true,
                                    title: Text(entry.date,
                                        style: const TextStyle(fontSize: 13)),
                                    subtitle: Text(entry.time,
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                    trailing: Icon(
                                      entry.taken
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: entry.taken
                                          ? AppColors.secondary
                                          : AppColors.danger,
                                      size: 20,
                                    ),
                                  ))
                              .toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
