import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'record_detail_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  List<HealthRecordModel> _records = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  // TODO(migration): -> HealthRecordBloc: HealthRecordsRequested event
  // (remote-first with Hive fallback, same pattern as your Product module)
  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await MockApiService.instance.getHealthRecords();
      setState(() {
        _records = result;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'prescription':
        return Icons.receipt_long_outlined;
      case 'lab_report':
        return Icons.biotech_outlined;
      case 'imaging':
        return Icons.image_outlined;
      case 'vaccination':
        return Icons.vaccines_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? _records
        : _records.where((r) => r.type == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('all', 'All'),
                  _filterChip('prescription', 'Prescriptions'),
                  _filterChip('lab_report', 'Lab Reports'),
                  _filterChip('imaging', 'Imaging'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingView()
                : _hasError
                    ? ErrorView(
                        message: 'Could not load records',
                        onRetry: _loadRecords)
                    : filtered.isEmpty
                        ? const EmptyView(
                            message: 'No records found',
                            icon: Icons.folder_off_outlined)
                        : RefreshIndicator(
                            onRefresh: _loadRecords,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final record = filtered[index];
                                return ListTile(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            RecordDetailScreen(record: record)),
                                  ),
                                  tileColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                        color: AppColors.border),
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(_iconForType(record.type),
                                        color: AppColors.primary),
                                  ),
                                  title: Text(record.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  subtitle: Text(
                                      '${record.date}${record.relatedDoctorName != null ? ' · ${record.relatedDoctorName}' : ''}',
                                      style: const TextStyle(fontSize: 12)),
                                  trailing: const Icon(Icons.chevron_right,
                                      color: AppColors.textSecondary),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Upload flow — hook up image_picker / file_picker here')),
          );
        },
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload'),
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : AppColors.textPrimary)),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary,
      ),
    );
  }
}
