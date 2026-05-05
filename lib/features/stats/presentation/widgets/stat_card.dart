import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/stats.dart';
import '../../domain/rank.dart';
import '../rank_color.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.stat,
    required this.onTap,
    required this.onChange,
  });
  final Stat stat;
  final void Function(Stat) onTap;
  final Future<void> Function(Stat, int) onChange;

  @override
  Widget build(BuildContext context) {
    final rank = rankFor(stat.total);
    final leagueColor = rankColor(rank.name);
    return InkWell(
      onTap: () => onTap(stat),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 84,
              height: 126,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(stat.imageAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${stat.total}',
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: leagueColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: leagueColor.withValues(alpha: .4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedAward05,
                          size: 15,
                          color: leagueColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          rank.name,
                          style: TextStyle(
                            color: leagueColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundIcon(
                  icon: HugeIcons.strokeRoundedPlusSign,
                  onTap: () => onChange(stat, 1),
                  color: stat.color,
                ),
                const SizedBox(height: 8),
                _RoundIcon(
                  icon: HugeIcons.strokeRoundedMinusSign,
                  onTap: stat.total == 0 ? null : () => onChange(stat, -1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap, this.color});
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    onPressed: onTap,
    style: IconButton.styleFrom(
      backgroundColor: (color ?? Colors.white).withValues(
        alpha: onTap == null ? .04 : .12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    icon: HugeIcon(
      icon: icon,
      size: 18,
      color: onTap == null ? Colors.white24 : color ?? Colors.white,
    ),
  );
}
