import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';

/// Pushed with the list screen's [MedicineBloc] still in the widget tree
/// (via `BlocProvider.value` in `MedicineListScreen`), so a successful save
/// dispatches straight into the same bloc instance and `Navigator.pop` alone
/// is enough — no separate "did it save?" round trip is needed, and the list
/// screen's `BlocBuilder` picks up the refreshed list automatically once
/// `MedicineAddRequested`'s handler refetches.
class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _frequency = 'once_daily';
  final List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];

  final _frequencyOptions = const [
    'once_daily',
    'twice_daily',
    'three_times_daily',
    'as_needed',
  ];

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
        context: context, initialTime: _reminderTimes[index]);
    if (picked != null) {
      setState(() => _reminderTimes[index] = picked);
    }
  }

  void _addTimeSlot() {
    setState(() => _reminderTimes.add(const TimeOfDay(hour: 20, minute: 0)));
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    context.read<MedicineBloc>().add(MedicineAddRequested(
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          frequency: _frequency,
          reminderTimes: _reminderTimes.map(_formatTime).toList(),
          instructions: _instructionsController.text.trim().isEmpty
              ? 'No special instructions'
              : _instructionsController.text.trim(),
        ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicineBloc, MedicineState>(
      listenWhen: (previous, current) =>
          previous.isAdding && !current.isAdding,
      listener: (context, state) {
        if (state.errorMessage == null) {
          context.pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Medicine')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Medicine Name',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter medicine name' : null,
                  decoration:
                      const InputDecoration(hintText: 'e.g. Napa Extra'),
                ),
                const SizedBox(height: 16),
                const Text('Dosage',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dosageController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter dosage' : null,
                  decoration: const InputDecoration(hintText: 'e.g. 1 tablet'),
                ),
                const SizedBox(height: 16),
                const Text('Frequency',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  items: _frequencyOptions
                      .map((f) => DropdownMenuItem(
                          value: f, child: Text(f.replaceAll('_', ' '))))
                      .toList(),
                  onChanged: (v) => setState(() => _frequency = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reminder Times',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    TextButton.icon(
                      onPressed: _addTimeSlot,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add time'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_reminderTimes.length, (index) {
                    return ActionChip(
                      avatar: const Icon(Icons.access_time,
                          size: 16, color: AppColors.primary),
                      label: Text(_formatTime(_reminderTimes[index])),
                      onPressed: () => _pickTime(index),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Instructions (optional)',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(hintText: 'e.g. Take after meal'),
                ),
                const SizedBox(height: 28),
                BlocBuilder<MedicineBloc, MedicineState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.isAdding ? null : _handleSave,
                      child: state.isAdding
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Text('Save Medicine'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
