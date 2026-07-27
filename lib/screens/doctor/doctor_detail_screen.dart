import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../booking/booking_confirm_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DoctorModel? _doctor;
  bool _isLoading = true;
  bool _hasError = false;
  int _selectedDateIndex = 0;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final doctor =
          await MockApiService.instance.getDoctorById(widget.doctorId);
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingView());
    }
    if (_hasError || _doctor == null) {
      return Scaffold(
          body: ErrorView(
              message: 'Could not load doctor details', onRetry: _loadDoctor));
    }
    final doctor = _doctor!;
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(doctor.photoUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 90, height: 90, color: AppColors.border)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(doctor.specializationName,
                          style: const TextStyle(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('${doctor.hospital}\n${doctor.location}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statTile(Icons.star, '${doctor.rating}',
                    '${doctor.reviewCount} reviews'),
                _statTile(Icons.work_outline, '${doctor.experienceYears}+',
                    'years exp'),
                _statTile(Icons.payments_outlined, '৳${doctor.consultationFee}',
                    'fee'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('About',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text(doctor.bio,
                style: const TextStyle(
                    color: AppColors.textSecondary, height: 1.4)),
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
            const SizedBox(height: 20),
            const Text('Select Date',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: doctor.availableSlots.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final group = doctor.availableSlots[index];
                  final selected = index == _selectedDateIndex;
                  return ChoiceChip(
                    label: Text(group.date),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _selectedDateIndex = index;
                      _selectedSlot = null;
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Time',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  doctor.availableSlots[_selectedDateIndex].slots.map((slot) {
                final selected = _selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSlot = slot),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary),
                );
              }).toList(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedSlot == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmScreen(
                          doctor: doctor,
                          date: doctor.availableSlots[_selectedDateIndex].date,
                          time: _selectedSlot!,
                        ),
                      ),
                    ),
            child: const Text('Continue to Book'),
          ),
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
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
