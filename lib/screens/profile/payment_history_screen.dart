import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/mock_api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<PaymentModel> _payments = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await MockApiService.instance.getPayments();
      setState(() {
        _payments = result;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.secondary;
      case 'refunded':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: _isLoading
          ? const LoadingView()
          : _hasError
              ? ErrorView(message: 'Could not load payments', onRetry: _loadPayments)
              : _payments.isEmpty
                  ? const EmptyView(message: 'No payments yet', icon: Icons.payments_outlined)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _payments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = _payments[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _statusColor(p.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.receipt_outlined, color: _statusColor(p.status)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.transactionId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    Text('${p.method.toUpperCase()} · ${p.paidAt.split('T').first}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('৳${p.amount}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(p.status, style: TextStyle(fontSize: 11, color: _statusColor(p.status))),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
