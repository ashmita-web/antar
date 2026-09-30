import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/gap_entry.dart';
import '../../data/models/village.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';

class VillageBottomSheet extends ConsumerWidget {
  const VillageBottomSheet({
    super.key,
    required this.village,
    required this.scrollController,
  });

  final Village village;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gapAsync = ref.watch(gapMatrixProvider);
    final aiCacheAsync = ref.watch(aiCacheProvider);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AntarSpacing.md),
      children: [
        // Village header
        Text(
          village.villageName,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AntarSpacing.xs),
        Text(
          '${village.block} · ${village.district}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AntarSpacing.md),

        // Population card
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AntarSpacing.md),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.people,
                  label: 'Population',
                  value: village.population.toString(),
                ),
                const SizedBox(width: AntarSpacing.lg),
                _InfoChip(
                  icon: Icons.home,
                  label: 'Households',
                  value: village.households.toString(),
                ),
              ],
            ),
          ),
        ),
        if (village.coordApprox) ...[
          const SizedBox(height: AntarSpacing.xs),
          Text(
            'Approx. location',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: AntarSpacing.md),

        // Indicators
        Text('Infrastructure Indicators', style: theme.textTheme.titleMedium),
        const SizedBox(height: AntarSpacing.sm),
        _IndicatorBar(label: 'Road (Pucca)', value: village.roadPuccaPct),
        _IndicatorBar(label: 'Tap Water', value: village.tapWaterPct),
        _IndicatorBar(label: 'Sanitation', value: village.toiletPct),
        _IndicatorBar(label: 'Electricity', value: village.electricityPct),
        _IndicatorBar(label: 'Internet', value: village.internetPct),
        _BoolIndicator(label: 'Health Center <5km', value: village.healthCenterWithin5km == 1),
        _BoolIndicator(label: 'School <3km', value: village.schoolWithin3km == 1),
        _BoolIndicator(label: 'Bank <5km', value: village.bankWithin5km == 1),
        _BoolIndicator(label: 'Bus Stop <5km', value: village.busStopWithin5km == 1),

        const SizedBox(height: AntarSpacing.md),

        // Gap scores
        Text('Gap Analysis', style: theme.textTheme.titleMedium),
        const SizedBox(height: AntarSpacing.sm),
        gapAsync.when(
          data: (gaps) {
            final villageGaps = gaps
                .where((g) => g.villageCode == village.villageCode)
                .toList()
              ..sort((a, b) => b.priority.compareTo(a.priority));

            return Column(
              children: [
                for (final g in villageGaps)
                  _GapRow(gap: g),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),

        const SizedBox(height: AntarSpacing.md),

        // AI explanation
        Text('AI Explanation', style: theme.textTheme.titleMedium),
        const SizedBox(height: AntarSpacing.sm),
        aiCacheAsync.when(
          data: (cache) {
            final entry = cache[village.villageCode] as Map<String, dynamic>?;
            if (entry == null) {
              return Text(
                'No AI analysis available for this village.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AntarSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AntarSpacing.xs),
                        Text(
                          'Cached AI Analysis',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AntarSpacing.sm),
                    Text(
                      entry['explanation'] as String? ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),

      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _IndicatorBar extends StatelessWidget {
  const _IndicatorBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = value / 100.0;
    final color = pct > 0.7
        ? AntarColors.stable
        : pct > 0.4
            ? AntarColors.phantomDemand
            : AntarColors.trueHotspot;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: color,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${value.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoolIndicator extends StatelessWidget {
  const _BoolIndicator({required this.label, required this.value});
  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AntarColors.stable : AntarColors.trueHotspot,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            value ? 'Yes' : 'No',
            style: theme.textTheme.labelSmall?.copyWith(
              color: value ? AntarColors.stable : AntarColors.trueHotspot,
            ),
          ),
        ],
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  const _GapRow({required this.gap});
  final GapEntry gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = gap.quadrantEnum;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(q.icon, color: q.color, size: 14),
          const SizedBox(width: 4),
          SizedBox(
            width: 80,
            child: Text(
              gap.category,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _ScoreBadge(label: 'D', value: gap.demand),
                _ScoreBadge(label: 'Def', value: gap.deficit),
                _ScoreBadge(label: 'C', value: gap.coverage),
                _ScoreBadge(label: 'P', value: gap.priority, highlight: true),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: q.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              q.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: q.color,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.label, required this.value, this.highlight = false});
  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: highlight ? FontWeight.bold : null,
          color: highlight ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }
}
