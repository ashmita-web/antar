import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/citizen_request.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';
import 'citizen_providers.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(requestsProvider);
    final selectedLang = ref.watch(citizenLanguageProvider);
    final myRequests = ref.watch(myRequestsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AntarSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AntarSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                      const SizedBox(width: AntarSpacing.sm),
                      Expanded(
                        child: Text(
                          'Your voice matters',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AntarSpacing.xs),
                  Text(
                    'Report infrastructure needs in your village. '
                    'Speak in your language — we understand.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AntarSpacing.md),

          // Language picker
          Text('Your language', style: theme.textTheme.titleSmall),
          const SizedBox(height: AntarSpacing.xs),
          Wrap(
            spacing: AntarSpacing.xs,
            runSpacing: AntarSpacing.xs,
            children: [
              for (final lang in _languages)
                ChoiceChip(
                  label: Text(lang.label),
                  selected: selectedLang == lang.code,
                  onSelected: (_) =>
                      ref.read(citizenLanguageProvider.notifier).state =
                          lang.code,
                ),
            ],
          ),
          const SizedBox(height: AntarSpacing.lg),

          // Community stats
          Text('Community snapshot', style: theme.textTheme.titleSmall),
          const SizedBox(height: AntarSpacing.sm),
          requestsAsync.when(
            data: (requests) => _CommunityStats(requests: requests),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: AntarSpacing.lg),

          // My recent submissions
          Text('My recent reports', style: theme.textTheme.titleSmall),
          const SizedBox(height: AntarSpacing.sm),
          if (myRequests.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AntarSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: AntarSpacing.sm),
                    Expanded(
                      child: Text(
                        'No reports yet. Tap "Report" to share your first need.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final req in myRequests.take(3))
              _RecentRequestCard(request: req),

        ],
      ),
    );
  }
}

class _CommunityStats extends StatelessWidget {
  const _CommunityStats({required this.requests});
  final List<CitizenRequest> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = <String, int>{};
    final languages = <String>{};
    for (final r in requests) {
      categories[r.category] = (categories[r.category] ?? 0) + 1;
      languages.add(r.languageName);
    }

    final topCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Row(
          children: [
            _StatCard(
              label: 'Total requests',
              value: '${requests.length}',
              icon: Icons.campaign,
            ),
            const SizedBox(width: AntarSpacing.sm),
            _StatCard(
              label: 'Languages',
              value: '${languages.length}',
              icon: Icons.translate,
            ),
          ],
        ),
        const SizedBox(height: AntarSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AntarSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top needs', style: theme.textTheme.labelLarge),
                const SizedBox(height: AntarSpacing.xs),
                for (final entry in topCategories.take(5))
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _categoryLabel(entry.key),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AntarSpacing.xs),
                        SizedBox(
                          width: 80,
                          child: LinearProgressIndicator(
                            value: entry.value / requests.length,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _categoryLabel(String cat) =>
      cat[0].toUpperCase() + cat.substring(1);
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AntarSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AntarSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRequestCard extends StatelessWidget {
  const _RecentRequestCard({required this.request});
  final CitizenRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AntarSpacing.xs),
      child: ListTile(
        leading: Icon(
          _categoryIcon(request.category),
          color: theme.colorScheme.primary,
        ),
        title: Text(request.summaryEn, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${request.villageName} · ${request.languageName}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: _StatusChip(status: request.status),
      ),
    );
  }

  IconData _categoryIcon(String cat) => switch (cat) {
        'road' => Icons.add_road,
        'water' => Icons.water_drop,
        'sanitation' => Icons.sanitizer,
        'electricity' => Icons.bolt,
        'health' => Icons.local_hospital,
        'education' => Icons.school,
        'internet' => Icons.wifi,
        'banking' => Icons.account_balance,
        'transport' => Icons.directions_bus,
        _ => Icons.report,
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'submitted' => (Colors.blue, 'Submitted'),
      'acknowledged' => (Colors.orange, 'Acknowledged'),
      'in_progress' => (Colors.purple, 'In progress'),
      'completed' => (Colors.green, 'Completed'),
      _ => (Colors.grey, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AntarRadius.chip),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LangOption {
  const _LangOption(this.code, this.label);
  final String code;
  final String label;
}

const _languages = [
  _LangOption('hi', 'हिन्दी'),
  _LangOption('en', 'English'),
  _LangOption('ta', 'தமிழ்'),
  _LangOption('bn', 'বাংলা'),
  _LangOption('pt', 'Português'),
];
