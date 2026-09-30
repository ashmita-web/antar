import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/providers.dart';
import '../../data/models/gap_entry.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final region = ref.watch(appRegionProvider);
    final requestsAsync = ref.watch(requestsProvider);
    final gapAsync = ref.watch(gapMatrixProvider);
    final candidatesAsync = ref.watch(candidatesProvider);

    return ListView(
      padding: const EdgeInsets.all(AntarSpacing.md),
      children: [
        Text(
          'Constituency Overview',
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          region == AppRegion.india
              ? 'Varanasi, India'
              : 'São Paulo Leste, Brazil',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AntarSpacing.lg),
        // KPI cards
        requestsAsync.when(
          data: (requests) {
            final languages = requests.map((r) => r.language).toSet();
            return gapAsync.when(
              data: (gaps) {
                final silentGapVillages = gaps
                    .where((g) => g.quadrant == 'silent_gap')
                    .map((g) => g.villageCode)
                    .toSet();
                final avgPriority = gaps.isEmpty
                    ? 0.0
                    : gaps.fold<double>(0, (s, g) => s + g.priority) / gaps.length;

                return Wrap(
                  spacing: AntarSpacing.md,
                  runSpacing: AntarSpacing.md,
                  children: [
                    _KpiCard(
                      icon: Icons.message_outlined,
                      label: 'Requests',
                      value: requests.length.toString(),
                      color: theme.colorScheme.primary,
                    ),
                    _KpiCard(
                      icon: Icons.language,
                      label: 'Languages',
                      value: languages.length.toString(),
                      color: AntarColors.accent,
                    ),
                    _KpiCard(
                      icon: AntarIcons.silentGap,
                      label: 'Silent Gaps',
                      value: silentGapVillages.length.toString(),
                      color: AntarColors.silentGap,
                    ),
                    _KpiCard(
                      icon: Icons.priority_high,
                      label: 'Avg Priority',
                      value: avgPriority.toStringAsFixed(2),
                      color: AntarColors.trueHotspot,
                    ),
                  ],
                );
              },
              loading: () => const _KpiShimmer(),
              error: (e, _) => _ErrorCard(message: e.toString()),
            );
          },
          loading: () => const _KpiShimmer(),
          error: (e, _) => _ErrorCard(message: e.toString()),
        ),
        const SizedBox(height: AntarSpacing.xl),
        Text(
          'Top 5 Priorities',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AntarSpacing.sm),
        candidatesAsync.when(
          data: (candidates) {
            final top5 = candidates.take(5).toList();
            if (top5.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AntarSpacing.lg),
                  child: Center(
                    child: Text(
                      'No priority data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final (i, c) in top5.indexed)
                  _PriorityTile(rank: i + 1, candidate: c),
              ],
            );
          },
          loading: () => const _KpiShimmer(),
          error: (e, _) => _ErrorCard(message: e.toString()),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 160,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AntarSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AntarSpacing.sm),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(color: color),
              ),
              const SizedBox(height: AntarSpacing.xs),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({required this.rank, required this.candidate});

  final int rank;
  final dynamic candidate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = candidate;
    final quadrant = GapEntry(
      villageCode: '',
      category: '',
      demand: 0,
      deficit: 0,
      coverage: 0,
      priority: 0,
      quadrant: c.quadrant,
    ).quadrantEnum;

    return Card(
      margin: const EdgeInsets.only(bottom: AntarSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: quadrant.color.withValues(alpha: 0.15),
          child: Text(
            '$rank',
            style: theme.textTheme.titleMedium?.copyWith(color: quadrant.color),
          ),
        ),
        title: Text(c.projectLabel),
        subtitle: Text(
          '${c.villageName} · ${c.block} · Priority ${c.priority.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(quadrant.icon, color: quadrant.color, size: 18),
            const SizedBox(width: AntarSpacing.xs),
            Text(
              quadrant.label,
              style: theme.textTheme.labelSmall?.copyWith(color: quadrant.color),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiShimmer extends StatelessWidget {
  const _KpiShimmer();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AntarSpacing.md,
      runSpacing: AntarSpacing.md,
      children: List.generate(4, (_) {
        return SizedBox(
          width: 160,
          height: 100,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AntarSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AntarSpacing.md),
        child: Text(
          'Something went wrong loading data.\n$message',
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}
