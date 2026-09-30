import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/gap_entry.dart';
import '../../data/models/village.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';
import '../map/village_bottom_sheet.dart';

class QuadrantScreen extends ConsumerWidget {
  const QuadrantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villagesAsync = ref.watch(villagesProvider);
    final gapAsync = ref.watch(gapMatrixProvider);

    return villagesAsync.when(
      data: (villages) => gapAsync.when(
        data: (gaps) => _QuadrantBody(villages: villages, gaps: gaps),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _QuadrantBody extends StatelessWidget {
  const _QuadrantBody({required this.villages, required this.gaps});

  final List<Village> villages;
  final List<GapEntry> gaps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final villageMap = {for (final v in villages) v.villageCode: v};

    // Aggregate: per village, average demand and deficit across categories
    final villageAgg = <String, _VillageAgg>{};
    for (final g in gaps) {
      final agg = villageAgg.putIfAbsent(
        g.villageCode,
        () => _VillageAgg(),
      );
      agg.demands.add(g.demand);
      agg.deficits.add(g.deficit);
      agg.priorities.add(g.priority);
      agg.quadrants.add(g.quadrant);
    }

    // Build scatter spots
    final spots = <ScatterSpot>[];
    final spotVillages = <int, Village>{};
    var idx = 0;

    for (final entry in villageAgg.entries) {
      final v = villageMap[entry.key];
      if (v == null) continue;
      final agg = entry.value;
      final avgDemand = agg.demands.reduce((a, b) => a + b) / agg.demands.length;
      final avgDeficit = agg.deficits.reduce((a, b) => a + b) / agg.deficits.length;
      final dominantQ = _dominantQuadrant(agg.quadrants);
      final q = GapEntry(
        villageCode: '',
        category: '',
        demand: 0,
        deficit: 0,
        coverage: 0,
        priority: 0,
        quadrant: dominantQ,
      ).quadrantEnum;

      spots.add(ScatterSpot(
        avgDemand,
        avgDeficit,
        dotPainter: FlDotCirclePainter(
          color: q.color.withValues(alpha: 0.7),
          strokeColor: q.color,
          strokeWidth: 1,
          radius: 4 + agg.priorities.reduce((a, b) => a > b ? a : b) * 8,
        ),
      ));
      spotVillages[idx] = v;
      idx++;
    }

    return Padding(
      padding: const EdgeInsets.all(AntarSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Demand vs Deficit', style: theme.textTheme.titleLarge),
          const SizedBox(height: AntarSpacing.xs),
          Text(
            'Each dot is a village. Size = max priority. Tap to inspect.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AntarSpacing.sm),
          // Legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final q in Quadrant.values) ...[
                Icon(q.icon, color: q.color, size: 14),
                const SizedBox(width: 2),
                Text(
                  q.label,
                  style: theme.textTheme.labelSmall?.copyWith(color: q.color),
                ),
                const SizedBox(width: AntarSpacing.md),
              ],
            ],
          ),
          const SizedBox(height: AntarSpacing.sm),
          Expanded(
            child: ScatterChart(
              ScatterChartData(
                minX: 0,
                maxX: 1,
                minY: 0,
                maxY: 1,
                scatterSpots: spots,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.5,
                  verticalInterval: 0.5,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: theme.colorScheme.outlineVariant,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: theme.colorScheme.outlineVariant,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Demand →',
                      style: theme.textTheme.labelSmall,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.25,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(
                      'Deficit →',
                      style: theme.textTheme.labelSmall,
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.25,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent &&
                        response != null &&
                        response.touchedSpot != null) {
                      final spotIdx = response.touchedSpot!.spotIndex;
                      final village = spotVillages[spotIdx];
                      if (village != null) {
                        _showVillageSheet(context, village);
                      }
                    }
                  },
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipItems: (spot) {
                      final village = spotVillages[spots.indexOf(spot)];
                      return ScatterTooltipItem(
                        village?.villageName ?? '',
                        textStyle: theme.textTheme.labelSmall!,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Quadrant labels
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AntarSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '↙ Stable',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AntarColors.stable,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '↘ Phantom Demand',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AntarColors.phantomDemand,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVillageSheet(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => VillageBottomSheet(
          village: village,
          scrollController: scrollController,
        ),
      ),
    );
  }

  String _dominantQuadrant(List<String> quadrants) {
    final counts = <String, int>{};
    for (final q in quadrants) {
      counts[q] = (counts[q] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class _VillageAgg {
  final demands = <double>[];
  final deficits = <double>[];
  final priorities = <double>[];
  final quadrants = <String>[];
}
