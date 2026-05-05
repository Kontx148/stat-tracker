import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_theme.dart';
import '../../stats/data/stat_repository.dart';
import '../domain/day_slice.dart';

class WeeklyPage extends StatefulWidget {
  const WeeklyPage({super.key, required this.repository});
  final StatRepository repository;

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {
  late Future<Map<String, List<DaySlice>>> _future;
  String? selectedDay;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.week();
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<Map<String, List<DaySlice>>>(
    future: _future,
    builder: (_, snap) {
      final map = snap.data ?? {};
      final days = [
        for (var i = 6; i >= 0; i--) DateTime.now().subtract(Duration(days: i)),
      ];
      selectedDay ??= dayKey(days.last);
      final selected = map[selectedDay] ?? const <DaySlice>[];
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 days', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in days)
                    Expanded(
                      child: _DayBar(
                        date: d,
                        slices: map[dayKey(d)] ?? const [],
                        selected: selectedDay == dayKey(d),
                        onFocus: () => setState(() => selectedDay = dayKey(d)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _DayDetails(day: selectedDay!, slices: selected),
          ],
        ),
      );
    },
  );
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.date,
    required this.slices,
    required this.selected,
    required this.onFocus,
  });
  final DateTime date;
  final List<DaySlice> slices;
  final bool selected;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold(0, (sum, item) => sum + item.quantity);
    return MouseRegion(
      onEnter: (_) => onFocus(),
      child: GestureDetector(
        onTap: onFocus,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 216,
              width: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: .12)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppTheme.accent : Colors.white10,
                ),
              ),
              child: total == 0
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (final s in slices)
                          Expanded(
                            flex: s.quantity,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: s.color,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              shortDay(date),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : AppTheme.muted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({required this.day, required this.slices});
  final String day;
  final List<DaySlice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold(0, (sum, item) => sum + item.quantity);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedDrink,
                size: 20,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 8),
              Text(
                '$day · $total total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (slices.isEmpty)
            const Text(
              'No consumption logged',
              style: TextStyle(color: AppTheme.muted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in slices)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: s.color.withValues(alpha: .3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: s.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text('${s.name}: ${s.quantity}'),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
