import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../widgets/common_widgets.dart';
import '../bloc/doctor_list/doctor_list_bloc.dart';
import '../bloc/doctor_list/doctor_list_event.dart';
import '../bloc/doctor_list/doctor_list_state.dart';
import '../bloc/specialization/specialization_bloc.dart';
import '../bloc/specialization/specialization_event.dart';
import '../bloc/specialization/specialization_state.dart';
import '../widgets/doctor_card.dart';
import '../widgets/doctor_filter_sheet.dart';
import '../widgets/specialization_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<SpecializationBloc>()..add(const SpecializationRequested()),
        ),
        BlocProvider(
          create: (_) => sl<DoctorListBloc>()..add(const DoctorListRequested()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();

  void _onSpecializationTap(BuildContext context, String id) {
    final currentSelection = context.read<SpecializationBloc>().state.selectedId;
    final newSelection = currentSelection == id ? null : id;
    context.read<SpecializationBloc>().add(SpecializationSelected(id));
    context
        .read<DoctorListBloc>()
        .add(DoctorSpecializationFilterChanged(newSelection));
  }

  Future<void> _onFilterTap(BuildContext context) async {
    final doctorListBloc = context.read<DoctorListBloc>();
    final current = doctorListBloc.state;
    final result = await showDoctorFilterSheet(
      context,
      current: DoctorFilters(
        minRating: current.minRating,
        availableOnly: current.availableOnly ?? false,
        maxFee: current.maxFee,
      ),
    );
    if (result == null) return;
    doctorListBloc.add(DoctorFiltersChanged(
      minRating: result.minRating,
      availableOnly: result.availableOnly ? true : null,
      maxFee: result.maxFee,
    ));
  }

  Future<void> _onRefresh(BuildContext context) async {
    context
        .read<SpecializationBloc>()
        .add(const SpecializationRequested(resetSelection: true));
    context
        .read<DoctorListBloc>()
        .add(const DoctorListRequested(resetSpecializationFilter: true));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi, Rafiul 👋'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('home-search-field'),
                    controller: _searchController,
                    onChanged: (query) => context
                        .read<DoctorListBloc>()
                        .add(DoctorSearchChanged(query)),
                    decoration: const InputDecoration(
                      hintText: 'Search doctors, specializations...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<DoctorListBloc, DoctorListState>(
                  buildWhen: (previous, current) =>
                      previous.hasActiveFilters != current.hasActiveFilters,
                  builder: (context, state) => IconButton.filledTonal(
                    onPressed: () => _onFilterTap(context),
                    icon: Icon(
                      state.hasActiveFilters
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Specializations'),
            SizedBox(
              height: 90,
              child: _SpecializationList(onTap: _onSpecializationTap),
            ),
            const SizedBox(height: 12),
            BlocBuilder<DoctorListBloc, DoctorListState>(
              buildWhen: (previous, current) =>
                  previous.specializationId != current.specializationId,
              builder: (context, state) => SectionTitle(
                title: state.specializationId == null
                    ? 'Top Doctors'
                    : 'Filtered Doctors',
              ),
            ),
            const _DoctorList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SpecializationList extends StatelessWidget {
  final void Function(BuildContext context, String id) onTap;

  const _SpecializationList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecializationBloc, SpecializationState>(
      builder: (context, state) {
        switch (state.status) {
          case SpecializationStatus.initial:
          case SpecializationStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case SpecializationStatus.failure:
            return ErrorView(
              message: state.errorMessage ?? 'Could not load categories',
              onRetry: () => context
                  .read<SpecializationBloc>()
                  .add(const SpecializationRequested()),
            );
          case SpecializationStatus.success:
            if (state.specializations.isEmpty) {
              return const EmptyView(message: 'No specializations found');
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.specializations.length,
              itemBuilder: (context, index) {
                final spec = state.specializations[index];
                return SpecializationChip(
                  specialization: spec,
                  selected: state.selectedId == spec.id,
                  onTap: () => onTap(context, spec.id),
                );
              },
            );
        }
      },
    );
  }
}

class _DoctorList extends StatelessWidget {
  const _DoctorList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorListBloc, DoctorListState>(
      builder: (context, state) {
        switch (state.status) {
          case DoctorListStatus.initial:
          case DoctorListStatus.loading:
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            );
          case DoctorListStatus.failure:
            return ErrorView(
              message: state.errorMessage ?? 'Could not load doctors',
              onRetry: () => context
                  .read<DoctorListBloc>()
                  .add(const DoctorListRequested()),
            );
          case DoctorListStatus.empty:
            return const EmptyView(
              message: 'No doctors found',
              icon: Icons.search_off,
            );
          case DoctorListStatus.success:
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final doctor = state.doctors[index];
                return DoctorCard(
                  key: Key('doctor-card-${doctor.id}'),
                  doctor: doctor,
                  onTap: () => context
                      .push(AppRoutes.doctorDetailPath(doctor.id)),
                );
              },
            );
        }
      },
    );
  }
}
