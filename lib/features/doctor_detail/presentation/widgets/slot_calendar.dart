import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/doctor_detail.dart';

/// A self-built month-grid calendar (no third-party package). Only dates
/// present in [availableSlots] are selectable — everything else (past days,
/// days with no slots) renders disabled/greyed out.
class SlotCalendar extends StatefulWidget {
  final List<DoctorSlotGroup> availableSlots;
  final String? selectedDate;
  final ValueChanged<String> onDateSelected;

  const SlotCalendar({
    super.key,
    required this.availableSlots,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<SlotCalendar> createState() => _SlotCalendarState();
}

class _SlotCalendarState extends State<SlotCalendar> {
  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthLabels = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = _monthOf(_initialFocusDate());
  }

  DateTime _initialFocusDate() {
    if (widget.selectedDate != null) {
      final parsed = DateTime.tryParse(widget.selectedDate!);
      if (parsed != null) return parsed;
    }
    if (widget.availableSlots.isNotEmpty) {
      final parsed = DateTime.tryParse(widget.availableSlots.first.date);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  Map<String, DoctorSlotGroup> get _slotsByDate => {
        for (final g in widget.availableSlots) g.date: g,
      };

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  String _isoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final slotsByDate = _slotsByDate;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // DateTime.weekday: Mon=1..Sun=7. We want Sun=0 leading columns.
    final leadingEmpty = firstOfMonth.weekday % 7;
    final totalCells = leadingEmpty + daysInMonth;
    final trailingEmpty = (7 - totalCells % 7) % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${_monthLabels[_visibleMonth.month - 1]} ${_visibleMonth.year}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Row(
          children: _weekdayLabels
              .map((label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingEmpty + daysInMonth + trailingEmpty,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            if (index < leadingEmpty || index >= leadingEmpty + daysInMonth) {
              return const SizedBox.shrink();
            }
            final day = index - leadingEmpty + 1;
            final date =
                DateTime(_visibleMonth.year, _visibleMonth.month, day);
            final iso = _isoDate(date);
            final group = slotsByDate[iso];
            final hasSlots = group != null && group.slots.isNotEmpty;
            final isPast = date.isBefore(todayOnly);
            final isSelected = widget.selectedDate == iso;
            final isSelectable = hasSlots && !isPast;

            return Padding(
              padding: const EdgeInsets.all(3),
              child: InkWell(
                key: Key('slot-date-$iso'),
                onTap: isSelectable ? () => widget.onDateSelected(iso) : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : isSelectable
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isSelectable
                                  ? AppColors.primary
                                  : AppColors.textSecondary
                                      .withValues(alpha: 0.5),
                        ),
                      ),
                      if (hasSlots && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
