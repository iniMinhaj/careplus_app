import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/theme/app_theme.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final DoctorModel doctor;
  final String date;
  final String time;
  final String consultationType;
  final String reasonForVisit;

  const PaymentScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    required this.consultationType,
    required this.reasonForVisit,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'bkash';
  bool _isProcessing = false;

  final _methods = const [
    {
      'id': 'bkash',
      'name': 'bKash',
      'icon': Icons.account_balance_wallet_outlined
    },
    {
      'id': 'nagad',
      'name': 'Nagad',
      'icon': Icons.account_balance_wallet_outlined
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card_outlined
    },
  ];

  // TODO(migration): -> BookingBloc: PaymentSubmitted event, with
  // BookingState.processing / .success / .failure sealed states.
  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    try {
      final appointment = await MockApiService.instance.bookAppointment(
        doctor: widget.doctor,
        date: widget.date,
        time: widget.time,
        consultationType: widget.consultationType,
        reasonForVisit: widget.reasonForVisit,
        paymentMethod: _selectedMethod,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(appointment: appointment)),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.doctor.consultationFee + 20;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Payment Method',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            ..._methods.map((m) {
              final selected = _selectedMethod == m['id'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () =>
                      setState(() => _selectedMethod = m['id'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                          width: selected ? 1.5 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(m['icon'] as IconData, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(m['name'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                        Radio<String>(
                          value: m['id'] as String,
                          groupValue: _selectedMethod,
                          onChanged: (v) =>
                              setState(() => _selectedMethod = v!),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payable',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('৳$total',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text('Pay ৳$total'),
            ),
          ],
        ),
      ),
    );
  }
}
