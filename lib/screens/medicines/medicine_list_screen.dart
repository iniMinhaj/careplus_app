import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/common_widgets.dart';
import 'add_medicine_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<MedicineModel> _medicines = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  // TODO(migration): -> MedicineBloc: MedicineListRequested event
  Future<void> _loadMedicines() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await MockApiService.instance.getMedicines();
      setState(() {
        _medicines = result;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // TODO(migration): -> MedicineBloc: MarkTakenRequested event, optimistic
  // update in the reducer instead of a manual reload.
  Future<void> _markTaken(String medicineId, String time) async {
    await MockApiService.instance.markMedicineTaken(medicineId, time);
    _loadMedicines();
  }

  int get _adherencePercent {
    final today = DateTime.now().toIso8601String().split('T').first;
    int total = 0;
    int taken = 0;
    for (final med in _medicines.where((m) => m.isActive)) {
      for (final _ in med.reminderTimes) {
        total++;
      }
      taken += med.adherenceLog.where((l) => l.date == today && l.taken).length;
    }
    if (total == 0) return 0;
    return ((taken / total) * 100).clamp(0, 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines & Reminders')),
      body: _isLoading
          ? const LoadingView()
          : _hasError
              ? ErrorView(
                  message: 'Could not load medicines', onRetry: _loadMedicines)
              : RefreshIndicator(
                  onRefresh: _loadMedicines,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Today's Adherence",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                                SizedBox(height: 4),
                                Text('Keep it up!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Text('$_adherencePercent%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_medicines.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: EmptyView(
                              message: 'No medicines added yet',
                              icon: Icons.medication_outlined),
                        )
                      else
                        ..._medicines.map((med) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: MedicineCard(
                                medicine: med,
                                onMarkTaken: (time) => _markTaken(med.id, time),
                              ),
                            )),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
          if (added == true) _loadMedicines();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }
}
