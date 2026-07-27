import 'package:flutter/material.dart';
import '../../core/theme/app_color.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/common_widgets.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  // TODO(migration): -> AppointmentListBloc: AppointmentListRequested event
  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await MockApiService.instance.getAppointments();
      setState(() {
        _appointments = result;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _cancelAppointment(String id) async {
    await MockApiService.instance.cancelAppointment(id);
    _loadAppointments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')),
      );
    }
  }

  List<AppointmentModel> _filterByStatus(String status) {
    if (status == 'upcoming') {
      return _appointments
          .where((a) => a.status == 'upcoming' || a.status == 'ongoing')
          .toList();
    }
    return _appointments.where((a) => a.status == status).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingView()
          : _hasError
              ? ErrorView(
                  message: 'Could not load appointments',
                  onRetry: _loadAppointments)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_filterByStatus('upcoming'), showCancel: true),
                    _buildList(_filterByStatus('completed')),
                    _buildList(_filterByStatus('cancelled')),
                  ],
                ),
    );
  }

  Widget _buildList(List<AppointmentModel> items, {bool showCancel = false}) {
    if (items.isEmpty) {
      return const EmptyView(
          message: 'Nothing here yet', icon: Icons.event_busy_outlined);
    }
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final appt = items[index];
          return AppointmentCard(
            appointment: appt,
            onCancel: showCancel ? () => _cancelAppointment(appt.id) : null,
          );
        },
      ),
    );
  }
}
