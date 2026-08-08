import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DoctorFilters {
  final double? minRating;
  final bool availableOnly;
  final int? maxFee;

  const DoctorFilters({this.minRating, this.availableOnly = false, this.maxFee});
}

const double _kMinFee = 500;
const double _kMaxFee = 1500;

/// Opens the filter bottom sheet and returns the submitted [DoctorFilters],
/// or null if the sheet was dismissed without applying.
Future<DoctorFilters?> showDoctorFilterSheet(
  BuildContext context, {
  required DoctorFilters current,
}) {
  return showModalBottomSheet<DoctorFilters>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _DoctorFilterSheetContent(initial: current),
  );
}

class _DoctorFilterSheetContent extends StatefulWidget {
  final DoctorFilters initial;

  const _DoctorFilterSheetContent({required this.initial});

  @override
  State<_DoctorFilterSheetContent> createState() =>
      _DoctorFilterSheetContentState();
}

class _DoctorFilterSheetContentState
    extends State<_DoctorFilterSheetContent> {
  late double? _minRating;
  late bool _availableOnly;
  late double _maxFee;

  @override
  void initState() {
    super.initState();
    _minRating = widget.initial.minRating;
    _availableOnly = widget.initial.availableOnly;
    _maxFee = (widget.initial.maxFee ?? _kMaxFee).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter doctors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            const Text('Minimum rating',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final ratingValue = (index + 1).toDouble();
                final selected = _minRating == ratingValue;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$index+ ★'),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _minRating = selected ? null : ratingValue;
                    }),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available today'),
              value: _availableOnly,
              onChanged: (value) => setState(() => _availableOnly = value),
            ),
            const SizedBox(height: 12),
            Text('Max consultation fee: ৳${_maxFee.round()}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _maxFee,
              min: _kMinFee,
              max: _kMaxFee,
              divisions: ((_kMaxFee - _kMinFee) / 100).round(),
              label: '৳${_maxFee.round()}',
              onChanged: (value) => setState(() => _maxFee = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      const DoctorFilters(),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: () => Navigator.pop(
                      context,
                      DoctorFilters(
                        minRating: _minRating,
                        availableOnly: _availableOnly,
                        maxFee: _maxFee == _kMaxFee ? null : _maxFee.round(),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
