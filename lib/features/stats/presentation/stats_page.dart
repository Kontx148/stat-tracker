import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/stat_repository.dart';
import '../domain/stats.dart';
import '../domain/rank.dart';
import 'rank_color.dart';
import 'widgets/add_stat_sheet.dart';
import 'widgets/empty_stats.dart';
import 'widgets/stat_card.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, required this.repository});
  final StatRepository repository;

  @override
  State<StatsPage> createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  late Future<List<Stat>> _stats;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    _stats = widget.repository.tracked();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      refresh();
    });
  }

  Future<void> _change(Stat stat, int delta) async {
    delta > 0
        ? await widget.repository.addStat(stat.id)
        : await widget.repository.removeStat(stat.id);
    await _reload();
  }

  Future<void> openAddSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          AddStatSheet(repository: widget.repository, onDone: _reload),
    );
  }

  void _details(Stat s) {
    final r = rankFor(s.total);
    final leagueColor = rankColor(r.name);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 78,
                  height: 112,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: s.color.withValues(alpha: .28)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset(s.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        s.last == null
                            ? 'Last consumed: never'
                            : 'Last consumed: ${s.last!.year}-${s.last!.month.toString().padLeft(2, '0')}-${s.last!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${s.total} consumed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: r.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: leagueColor,
              backgroundColor: Colors.white10,
            ),
            const SizedBox(height: 8),
            Text(
              r.next == null
                  ? '${r.name} - max rank'
                  : '${r.name} - ${r.next! - s.total} until next stage',
              style: TextStyle(color: leagueColor, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Stat>>(
    future: _stats,
    builder: (_, snap) {
      final stats = snap.data ?? [];
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      if (stats.isEmpty) return EmptyStats(onAdd: openAddSheet);
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: stats.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
            StatCard(stat: stats[i], onTap: _details, onChange: _change),
      );
    },
  );
}
