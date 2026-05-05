import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/stat_repository.dart';
import '../../domain/stats.dart';

class AddStatSheet extends StatelessWidget {
  const AddStatSheet({
    super.key,
    required this.repository,
    required this.onDone,
  });
  final StatRepository repository;
  final Future<void> Function() onDone;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Stat>>(
    future: repository.catalog(),
    builder: (_, snap) {
      final available = (snap.data ?? []).where((b) => !b.tracked).toList();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add beverage', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
              child: available.isEmpty
                  ? const Center(
                      child: Text(
                        'All presets added',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    )
                  : GridView.builder(
                      itemCount: available.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: .78,
                          ),
                      itemBuilder: (_, i) => _CatalogTile(
                        stat: available[i],
                        onAdd: () async {
                          await repository.track(available[i].id);
                          await onDone();
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    },
  );
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.stat, required this.onAdd});
  final Stat stat;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onAdd,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: .68,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(stat.imageAsset, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedPlusSignCircle,
                size: 20,
                color: stat.color,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
