import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/dependency.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/common_widgets.dart';
import '../../domain/entity/health_record.dart';
import '../bloc/health_records_bloc.dart';
import '../bloc/health_records_event.dart';
import '../bloc/health_records_state.dart';

const List<String> _recordTypes = [
  'prescription',
  'lab_report',
  'imaging',
  'vaccination',
  'other',
];

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HealthRecordsBloc>()..add(const HealthRecordsRequested()),
      child: const _HealthRecordsView(),
    );
  }
}

class _HealthRecordsView extends StatefulWidget {
  const _HealthRecordsView();

  @override
  State<_HealthRecordsView> createState() => _HealthRecordsViewState();
}

class _HealthRecordsViewState extends State<_HealthRecordsView> {
  String _filter = 'all';
  HealthRecordUploadStatus _lastUploadStatus = HealthRecordUploadStatus.idle;

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

  String _labelForType(String type) {
    switch (type) {
      case 'prescription':
        return 'Prescription';
      case 'lab_report':
        return 'Lab Report';
      case 'imaging':
        return 'Imaging';
      case 'vaccination':
        return 'Vaccination';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: BlocConsumer<HealthRecordsBloc, HealthRecordsState>(
        listener: (context, state) {
          if (state.uploadStatus != _lastUploadStatus) {
            _lastUploadStatus = state.uploadStatus;
            if (state.uploadStatus == HealthRecordUploadStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record uploaded successfully')),
              );
            } else if (state.uploadStatus == HealthRecordUploadStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      state.uploadErrorMessage ?? 'Failed to upload record'),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final filtered = _filter == 'all'
              ? state.records
              : state.records.where((r) => r.type == _filter).toList();
          final isUploading =
              state.uploadStatus == HealthRecordUploadStatus.uploading;

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: _buildBody(context, state, filtered),
                  ),
                ],
              ),
              if (isUploading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 3),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadSheet(context),
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HealthRecordsState state,
    List<HealthRecord> filtered,
  ) {
    switch (state.status) {
      case HealthRecordsStatus.initial:
      case HealthRecordsStatus.loading:
        return const LoadingView();
      case HealthRecordsStatus.failure:
        return ErrorView(
          message: state.errorMessage ?? 'Could not load records',
          onRetry: () => context
              .read<HealthRecordsBloc>()
              .add(const HealthRecordsRequested()),
        );
      case HealthRecordsStatus.success:
        if (filtered.isEmpty) {
          return const EmptyView(
            message: 'No records found',
            icon: Icons.folder_off_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => context
              .read<HealthRecordsBloc>()
              .add(const HealthRecordsRequested()),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final record = filtered[index];
              return ListTile(
                onTap: () => context
                    .push(AppRoutes.healthRecordDetail, extra: record),
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
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
                        fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                    '${record.date}${record.relatedDoctorName != null ? ' · ${record.relatedDoctorName}' : ''}',
                    style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              );
            },
          ),
        );
    }
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

  Future<void> _showUploadSheet(BuildContext context) async {
    final bloc = context.read<HealthRecordsBloc>();
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = _recordTypes.first;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upload a record',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    const Text('Type',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recordTypes.map((type) {
                        final selected = selectedType == type;
                        return ChoiceChip(
                          label: Text(_labelForType(type),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary)),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          onSelected: (_) =>
                              setSheetState(() => selectedType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Choose file & upload'),
                        onPressed: () =>
                            Navigator.of(sheetContext).pop(true),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (confirmed != true) return;

    final pickedPath = await _pickFile();
    if (pickedPath == null) return; // cancelled — close quietly

    final fileName = pickedPath.split('/').last;
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    final fileType = extension == 'pdf' ? 'pdf' : 'image';

    final trimmedTitle = titleController.text.trim();
    final title = trimmedTitle.isEmpty
        ? 'Uploaded record — ${DateTime.now().toIso8601String().split('T').first}'
        : trimmedTitle;
    final notes = notesController.text.trim();

    bloc.add(HealthRecordUploadRequested(
      title: title,
      type: selectedType,
      filePath: pickedPath,
      fileType: fileType,
      notes: notes.isEmpty ? null : notes,
    ));
  }

  /// Wraps the file_picker call so a cancelled pick (null result) or an
  /// unavailable picker/denied permission never throws — it just resolves
  /// to null and the caller treats that as "user cancelled".
  Future<String?> _pickFile() async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      return result?.path;
    } catch (_) {
      return null;
    }
  }
}
