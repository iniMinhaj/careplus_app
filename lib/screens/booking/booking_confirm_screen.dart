import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'payment_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final DoctorModel doctor;
  final String date;
  final String time;

  const BookingConfirmScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  String _consultationType = 'video';
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(widget.doctor.photoUrl, width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.border)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(widget.doctor.specializationName, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                        Text('${widget.date} · ${widget.time}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Consultation Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                _typeOption('video', Icons.videocam_outlined, 'Video'),
                const SizedBox(width: 10),
                _typeOption('chat', Icons.chat_bubble_outline, 'Chat'),
                const SizedBox(width: 10),
                _typeOption('in-person', Icons.local_hospital_outlined, 'Visit'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Reason for visit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Briefly describe your symptoms or reason...'),
            ),
            const SizedBox(height: 20),
            _summaryRow('Consultation fee', '৳${widget.doctor.consultationFee}'),
            _summaryRow('Platform fee', '৳20'),
            const Divider(),
            _summaryRow('Total', '৳${widget.doctor.consultationFee + 20}', bold: true),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  doctor: widget.doctor,
                  date: widget.date,
                  time: widget.time,
                  consultationType: _consultationType,
                  reasonForVisit: _reasonController.text.trim().isEmpty
                      ? 'General consultation'
                      : _reasonController.text.trim(),
                ),
              ),
            ),
            child: const Text('Proceed to Payment'),
          ),
        ),
      ),
    );
  }

  Widget _typeOption(String value, IconData icon, String label) {
    final selected = _consultationType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _consultationType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, color: selected ? AppColors.primary : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}
