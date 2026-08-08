import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../widgets/common_widgets.dart';
import '../bloc/appointment_list_bloc.dart';
import '../bloc/appointment_list_event.dart';
import '../bloc/appointment_list_state.dart';
import '../widgets/appointment_tile.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AppointmentListBloc>()..add(const AppointmentListRequested()),
      child: const _AppointmentsView(),
    );
  }
}

class _AppointmentsView extends StatefulWidget {
  const _AppointmentsView();

  @override
  State<_AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<_AppointmentsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<AppointmentListBloc>().add(const AppointmentListRequested());
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
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: BlocConsumer<AppointmentListBloc, AppointmentListState>(
        listenWhen: (prev, curr) => prev.cancelledTick != curr.cancelledTick,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment cancelled')),
          );
        },
        builder: (context, state) {
          final isInitialLoad = state.status == AppointmentListStatus.loading &&
              state.appointments.isEmpty;
          if (isInitialLoad) {
            return const LoadingView();
          }
          final isInitialError = state.status == AppointmentListStatus.failure &&
              state.appointments.isEmpty;
          if (isInitialError) {
            return ErrorView(
              message: state.errorMessage ?? 'Could not load appointments',
              onRetry: () => context
                  .read<AppointmentListBloc>()
                  .add(const AppointmentListRequested()),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentList(
                appointments: state.upcoming,
                showCancel: true,
                onRefresh: _refresh,
              ),
              _AppointmentList(
                appointments: state.past,
                showCancel: false,
                onRefresh: _refresh,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final bool showCancel;
  final Future<void> Function() onRefresh;

  const _AppointmentList({
    required this.appointments,
    required this.showCancel,
    required this.onRefresh,
  });

  Future<void> _confirmCancel(BuildContext context, Appointment appt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Text(
          'This will cancel your appointment with ${appt.doctorName} on '
          '${appt.date} at ${appt.time}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppointmentListBloc>().add(AppointmentCancelRequested(appt.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const EmptyView(
                message: 'Nothing here yet',
                icon: Icons.event_busy_outlined,
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final appt = appointments[index];
          return AppointmentTile(
            appointment: appt,
            onTap: () =>
                context.push(AppRoutes.appointmentDetail, extra: appt),
            onCancel:
                showCancel ? () => _confirmCancel(context, appt) : null,
          );
        },
      ),
    );
  }
}
