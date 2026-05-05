import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_theme.dart';

class EmptyStats extends StatelessWidget {
  const EmptyStats({super.key, required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedSodaCan,
                  size: 40,
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No tracked beverages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: HugeIcon(icon: HugeIcons.strokeRoundedAddCircle, size: 18),
              label: const Text('Add beverage'),
            ),
          ],
        ),
      ),
    ),
  );
}
