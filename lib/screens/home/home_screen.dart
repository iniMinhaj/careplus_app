import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../widgets/specialization_chip.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/common_widgets.dart';
import '../doctor/doctor_detail_screen.dart';

enum _LoadState { loading, loaded, error, empty }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<SpecializationModel> _specializations = [];
  List<DoctorModel> _doctors = [];
  String? _selectedSpecializationId;
  _LoadState _specState = _LoadState.loading;
  _LoadState _doctorState = _LoadState.loading;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadSpecializations(), _loadDoctors()]);
  }

  // TODO(migration): -> SpecializationBloc: SpecializationRequested event
  Future<void> _loadSpecializations() async {
    setState(() => _specState = _LoadState.loading);
    try {
      final result = await MockApiService.instance.getSpecializations();
      setState(() {
        _specializations = result;
        _specState = result.isEmpty ? _LoadState.empty : _LoadState.loaded;
      });
    } catch (_) {
      setState(() => _specState = _LoadState.error);
    }
  }

  // TODO(migration): -> DoctorListBloc: DoctorListRequested / DoctorSearchChanged events
  Future<void> _loadDoctors({String? specializationId}) async {
    setState(() => _doctorState = _LoadState.loading);
    try {
      final result = await MockApiService.instance
          .getDoctors(specializationId: specializationId);
      setState(() {
        _doctors = result;
        _doctorState = result.isEmpty ? _LoadState.empty : _LoadState.loaded;
      });
    } catch (_) {
      setState(() => _doctorState = _LoadState.error);
    }
  }

  // Debounced search — this Timer-based logic is exactly what a `debounce`
  // transformer inside a BLoC (bloc_concurrency) or a Riverpod `Timer` in a
  // Notifier will replace.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() => _doctorState = _LoadState.loading);
      try {
        final result = await MockApiService.instance.searchDoctors(query);
        setState(() {
          _doctors = result;
          _doctorState = result.isEmpty ? _LoadState.empty : _LoadState.loaded;
        });
      } catch (_) {
        setState(() => _doctorState = _LoadState.error);
      }
    });
  }

  void _onSpecializationTap(String id) {
    setState(() {
      _selectedSpecializationId = _selectedSpecializationId == id ? null : id;
    });
    _loadDoctors(specializationId: _selectedSpecializationId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi, Rafiul 👋'),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search doctors, specializations...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Specializations'),
            SizedBox(
              height: 90,
              child: _buildSpecializations(),
            ),
            const SizedBox(height: 12),
            SectionTitle(
              title: _selectedSpecializationId == null
                  ? 'Top Doctors'
                  : 'Filtered Doctors',
            ),
            _buildDoctorList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializations() {
    switch (_specState) {
      case _LoadState.loading:
        return const Center(child: CircularProgressIndicator());
      case _LoadState.error:
        return ErrorView(
            message: 'Could not load categories',
            onRetry: _loadSpecializations);
      case _LoadState.empty:
        return const EmptyView(message: 'No specializations found');
      case _LoadState.loaded:
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _specializations.length,
          itemBuilder: (context, index) {
            final spec = _specializations[index];
            return SpecializationChip(
              specialization: spec,
              selected: _selectedSpecializationId == spec.id,
              onTap: () => _onSpecializationTap(spec.id),
            );
          },
        );
    }
  }

  Widget _buildDoctorList() {
    switch (_doctorState) {
      case _LoadState.loading:
        return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()));
      case _LoadState.error:
        return ErrorView(
            message: 'Could not load doctors', onRetry: () => _loadDoctors());
      case _LoadState.empty:
        return const EmptyView(
            message: 'No doctors found', icon: Icons.search_off);
      case _LoadState.loaded:
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doctor = _doctors[index];
            return DoctorCard(
              doctor: doctor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DoctorDetailScreen(doctorId: doctor.id)),
              ),
            );
          },
        );
    }
  }
}
