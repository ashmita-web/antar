import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/gap_entry.dart';
import '../../data/models/village.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';
import 'village_bottom_sheet.dart';

final _selectedCategoryProvider = StateProvider<String?>((ref) => null);

class GapMapScreen extends ConsumerWidget {
  const GapMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final villagesAsync = ref.watch(villagesProvider);
    final gapAsync = ref.watch(gapMatrixProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);

    return villagesAsync.when(
      data: (villages) => gapAsync.when(
        data: (gaps) => _MapBody(
          villages: villages,
          gaps: gaps,
          selectedCategory: selectedCategory,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _MapBody extends ConsumerWidget {
  const _MapBody({
    required this.villages,
    required this.gaps,
    required this.selectedCategory,
  });

  final List<Village> villages;
  final List<GapEntry> gaps;
  final String? selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Build village → dominant quadrant + max priority map
    final villageData = <String, _VillageMapData>{};
    for (final g in gaps) {
      if (selectedCategory != null && g.category != selectedCategory) continue;
      final existing = villageData[g.villageCode];
      if (existing == null || g.priority > existing.maxPriority) {
        villageData[g.villageCode] = _VillageMapData(
          quadrant: g.quadrantEnum,
          maxPriority: g.priority,
        );
      }
    }

    // Compute map center
    final validVillages = villages.where((v) => villageData.containsKey(v.villageCode)).toList();
    final center = validVillages.isEmpty
        ? const LatLng(25.3176, 82.9739)
        : LatLng(
            validVillages.map((v) => v.lat).reduce((a, b) => a + b) / validVillages.length,
            validVillages.map((v) => v.lon).reduce((a, b) => a + b) / validVillages.length,
          );

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.antar.app',
            ),
            MarkerLayer(
              markers: [
                for (final v in validVillages)
                  if (villageData.containsKey(v.villageCode))
                    _buildMarker(context, ref, v, villageData[v.villageCode]!),
              ],
            ),
          ],
        ),
        // Category filter chips
        Positioned(
          top: AntarSpacing.sm,
          left: AntarSpacing.sm,
          right: AntarSpacing.sm,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: selectedCategory == null,
                  onTap: () => ref.read(_selectedCategoryProvider.notifier).state = null,
                ),
                for (final cat in const [
                  'road', 'water', 'sanitation', 'electricity',
                  'health', 'education', 'internet', 'banking', 'transport',
                ])
                  _FilterChip(
                    label: cat[0].toUpperCase() + cat.substring(1),
                    selected: selectedCategory == cat,
                    onTap: () => ref.read(_selectedCategoryProvider.notifier).state = cat,
                  ),
              ],
            ),
          ),
        ),
        // Legend
        Positioned(
          bottom: AntarSpacing.md,
          right: AntarSpacing.md,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AntarSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final q in Quadrant.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(q.icon, color: q.color, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            q.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: q.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Marker _buildMarker(
    BuildContext context,
    WidgetRef ref,
    Village village,
    _VillageMapData data,
  ) {
    final size = 16.0 + data.maxPriority * 24;
    return Marker(
      point: LatLng(village.lat, village.lon),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _showVillageSheet(context, ref, village),
        child: Container(
          decoration: BoxDecoration(
            color: data.quadrant.color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: data.quadrant.color, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _showVillageSheet(BuildContext context, WidgetRef ref, Village village) {
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
}

class _VillageMapData {
  final Quadrant quadrant;
  final double maxPriority;
  const _VillageMapData({required this.quadrant, required this.maxPriority});
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AntarSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        selectedColor: theme.colorScheme.primaryContainer,
      ),
    );
  }
}
