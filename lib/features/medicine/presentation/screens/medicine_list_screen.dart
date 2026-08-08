import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/common_widgets.dart';
import '../bloc/medicine_bloc.dart';
import '../bloc/medicine_event.dart';
import '../bloc/medicine_state.dart';
import '../widgets/medicine_tile.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MedicineBloc>()..add(const MedicineListRequested()),
      child: const _MedicineListView(),
    );
  }
}

class _MedicineListView extends StatelessWidget {
  const _MedicineListView();

  Future<void> _onAddMedicine(BuildContext context) async {
    final bloc = context.read<MedicineBloc>();
    await context.push(AppRoutes.medicineAdd, extra: bloc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines & Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Adherence History',
            onPressed: () {
              final medicines = context.read<MedicineBloc>().state.medicines;
              context.push(AppRoutes.medicineAdherence, extra: medicines);
            },
          ),
        ],
      ),
      body: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          switch (state.status) {
            case MedicineListStatus.initial:
            case MedicineListStatus.loading:
              return const LoadingView();
            case MedicineListStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Could not load medicines',
                onRetry: () => context
                    .read<MedicineBloc>()
                    .add(const MedicineListRequested()),
              );
            case MedicineListStatus.success:
            case MedicineListStatus.empty:
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<MedicineBloc>()
                      .add(const MedicineListRequested());
                },
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
                          Text('${state.adherencePercentToday}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.medicines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: EmptyView(
                            message: 'No medicines added yet',
                            icon: Icons.medication_outlined),
                      )
                    else
                      ...state.medicines.map((med) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MedicineTile(
                              medicine: med,
                              onMarkTaken: (time) => context
                                  .read<MedicineBloc>()
                                  .add(MedicineMarkTakenRequested(
                                    medicineId: med.id,
                                    time: time,
                                  )),
                            ),
                          )),
                  ],
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddMedicine(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }
}
