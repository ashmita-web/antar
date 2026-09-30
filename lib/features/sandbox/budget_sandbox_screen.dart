import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/optimizer.dart';
import '../../core/providers.dart';
import '../../data/models/candidate_project.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';
import '../recommendation/recommendation_screen.dart';

final _budgetProvider = StateProvider<int>((ref) {
  final region = ref.watch(appRegionProvider);
  return region == AppRegion.brazil ? 1000000 : 50000000;
});

final _equityProvider = StateProvider<bool>((ref) => false);

final _selectedIdsProvider =
    StateNotifierProvider<_SelectedIdsNotifier, Set<String>>(
  (ref) => _SelectedIdsNotifier(),
);

class _SelectedIdsNotifier extends StateNotifier<Set<String>> {
  _SelectedIdsNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void setAll(Set<String> ids) => state = ids;
}

class BudgetSandboxScreen extends ConsumerWidget {
  const BudgetSandboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(candidatesProvider);

    return candidatesAsync.when(
      data: (candidates) => _SandboxBody(candidates: candidates),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _SandboxBody extends ConsumerStatefulWidget {
  const _SandboxBody({required this.candidates});
  final List<CandidateProject> candidates;

  @override
  ConsumerState<_SandboxBody> createState() => _SandboxBodyState();
}

class _SandboxBodyState extends ConsumerState<_SandboxBody> {
  OptimizationResult? _optimizedResult;
  bool _showComparison = false;

  int get _budgetUnit {
    final region = ref.read(appRegionProvider);
    return region == AppRegion.brazil ? 10000 : 100000;
  }

  int get _maxBudget {
    final region = ref.read(appRegionProvider);
    return region == AppRegion.brazil ? 3000000 : 150000000;
  }

  String get _currencySymbol {
    final region = ref.read(appRegionProvider);
    return region == AppRegion.brazil ? 'R\$' : '₹';
  }

  String _formatCurrency(int amount) {
    final region = ref.read(appRegionProvider);
    if (region == AppRegion.brazil) {
      return 'R\$ ${(amount / 1000).toStringAsFixed(0)}k';
    }
    if (amount >= 10000000) {
      return '$_currencySymbol ${(amount / 10000000).toStringAsFixed(1)} Cr';
    }
    if (amount >= 100000) {
      return '$_currencySymbol ${(amount / 100000).toStringAsFixed(1)} L';
    }
    return '$_currencySymbol $amount';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = ref.watch(_budgetProvider);
    final equity = ref.watch(_equityProvider);
    final selectedIds = ref.watch(_selectedIdsProvider);

    final selectedCandidates = widget.candidates
        .where((c) => selectedIds.contains(c.candidateId))
        .toList();
    final userCost =
        selectedCandidates.fold<int>(0, (s, c) => s + c.indicativeCost);
    final userBeneficiaries =
        selectedCandidates.fold<int>(0, (s, c) => s + c.beneficiaries);
    final budgetUsed = budget > 0 ? (userCost / budget).clamp(0.0, 1.5) : 0.0;

    return Column(
      children: [
        // Sticky budget bar
        _BudgetBar(
          budget: budget,
          spent: userCost,
          fraction: budgetUsed,
          currencySymbol: _currencySymbol,
          formatCurrency: _formatCurrency,
          onChanged: (v) => ref.read(_budgetProvider.notifier).state = v,
          maxBudget: _maxBudget,
        ),
        // KPI strip
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AntarSpacing.md,
            vertical: AntarSpacing.xs,
          ),
          child: Row(
            children: [
              _KpiChip(
                label: 'Selected',
                value: '${selectedCandidates.length}',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: AntarSpacing.sm),
              _KpiChip(
                label: 'Beneficiaries',
                value: _compactNumber(userBeneficiaries),
                icon: Icons.people_outline,
              ),
              const SizedBox(width: AntarSpacing.sm),
              _KpiChip(
                label: 'Remaining',
                value: _formatCurrency(
                    (budget - userCost).clamp(0, budget * 2)),
                icon: Icons.account_balance_wallet_outlined,
                alert: userCost > budget,
              ),
            ],
          ),
        ),
        // Action row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AntarSpacing.md),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AntarSpacing.xs,
            runSpacing: AntarSpacing.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch.adaptive(
                    value: equity,
                    onChanged: (v) =>
                        ref.read(_equityProvider.notifier).state = v,
                  ),
                  Text('Equity boost', style: theme.textTheme.labelMedium),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: '+30% weight for silent-gap villages',
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedCandidates.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: AntarSpacing.xs),
                      child: OutlinedButton.icon(
                        onPressed: () => _openLetter(
                          context,
                          selectedCandidates,
                          userCost,
                          userBeneficiaries,
                          budget,
                          equity,
                        ),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Letter'),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: () => _runOptimizer(budget, equity),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Optimize'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AntarSpacing.xs),
        // Comparison or project list
        Expanded(
          child: _showComparison && _optimizedResult != null
              ? _ComparisonView(
                  userSelected: selectedCandidates,
                  userCost: userCost,
                  userBeneficiaries: userBeneficiaries,
                  optimized: _optimizedResult!,
                  formatCurrency: _formatCurrency,
                  onApplyOptimized: _applyOptimized,
                  onDismiss: () => setState(() => _showComparison = false),
                )
              : _CandidateList(
                  candidates: widget.candidates,
                  selectedIds: selectedIds,
                  budget: budget,
                  userCost: userCost,
                  formatCurrency: _formatCurrency,
                  currencySymbol: _currencySymbol,
                ),
        ),
      ],
    );
  }

  void _runOptimizer(int budget, bool equity) {
    final result = optimizeBudget(
      candidates: widget.candidates,
      budget: budget,
      budgetUnit: _budgetUnit,
      equityBoost: equity,
    );
    setState(() {
      _optimizedResult = result;
      _showComparison = true;
    });
  }

  void _openLetter(
    BuildContext context,
    List<CandidateProject> selected,
    int cost,
    int beneficiaries,
    int budget,
    bool equity,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendationScreen(
          selected: selected,
          totalCost: cost,
          totalBeneficiaries: beneficiaries,
          budget: budget,
          equityEnabled: equity,
        ),
      ),
    );
  }

  void _applyOptimized() {
    if (_optimizedResult == null) return;
    ref.read(_selectedIdsProvider.notifier).setAll(
          _optimizedResult!.selected.map((c) => c.candidateId).toSet(),
        );
    setState(() => _showComparison = false);
  }

  String _compactNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({
    required this.budget,
    required this.spent,
    required this.fraction,
    required this.currencySymbol,
    required this.formatCurrency,
    required this.onChanged,
    required this.maxBudget,
  });

  final int budget;
  final int spent;
  final double fraction;
  final String currencySymbol;
  final String Function(int) formatCurrency;
  final ValueChanged<int> onChanged;
  final int maxBudget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overBudget = spent > budget;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AntarSpacing.md,
        AntarSpacing.sm,
        AntarSpacing.md,
        AntarSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Budget', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                '${formatCurrency(spent)} / ${formatCurrency(budget)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: overBudget
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AntarSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: overBudget
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          Slider(
            value: budget.toDouble(),
            min: 0,
            max: maxBudget.toDouble(),
            divisions: 30,
            label: formatCurrency(budget),
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AntarSpacing.sm,
          vertical: AntarSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: alert
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AntarRadius.chip),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: alert ? theme.colorScheme.error : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateList extends ConsumerWidget {
  const _CandidateList({
    required this.candidates,
    required this.selectedIds,
    required this.budget,
    required this.userCost,
    required this.formatCurrency,
    required this.currencySymbol,
  });

  final List<CandidateProject> candidates;
  final Set<String> selectedIds;
  final int budget;
  final int userCost;
  final String Function(int) formatCurrency;
  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...candidates]
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AntarSpacing.md),
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final c = sorted[i];
        final selected = selectedIds.contains(c.candidateId);
        final wouldExceed =
            !selected && (userCost + c.indicativeCost > budget);

        return _CandidateCard(
          candidate: c,
          selected: selected,
          wouldExceed: wouldExceed,
          formatCurrency: formatCurrency,
          onToggle: () =>
              ref.read(_selectedIdsProvider.notifier).toggle(c.candidateId),
        );
      },
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.selected,
    required this.wouldExceed,
    required this.formatCurrency,
    required this.onToggle,
  });

  final CandidateProject candidate;
  final bool selected;
  final bool wouldExceed;
  final String Function(int) formatCurrency;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _quadrantFromString(candidate.quadrant);

    return Card(
      margin: const EdgeInsets.only(bottom: AntarSpacing.xs),
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AntarRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AntarSpacing.sm),
          child: Row(
            children: [
              // Selection indicator
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
              const SizedBox(width: AntarSpacing.sm),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            candidate.projectLabel,
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: q.color.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AntarRadius.chip),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(q.icon, size: 12, color: q.color),
                              const SizedBox(width: 2),
                              Text(
                                q.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: q.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${candidate.villageName} · ${candidate.block}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _InfoTag(
                          icon: Icons.currency_rupee,
                          text: formatCurrency(candidate.indicativeCost),
                        ),
                        const SizedBox(width: AntarSpacing.sm),
                        _InfoTag(
                          icon: Icons.people_outline,
                          text: '${candidate.beneficiaries}',
                        ),
                        const SizedBox(width: AntarSpacing.sm),
                        _InfoTag(
                          icon: Icons.priority_high,
                          text: 'P ${candidate.priority.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    if (wouldExceed && !selected)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Exceeds remaining budget',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ComparisonView extends StatelessWidget {
  const _ComparisonView({
    required this.userSelected,
    required this.userCost,
    required this.userBeneficiaries,
    required this.optimized,
    required this.formatCurrency,
    required this.onApplyOptimized,
    required this.onDismiss,
  });

  final List<CandidateProject> userSelected;
  final int userCost;
  final int userBeneficiaries;
  final OptimizationResult optimized;
  final String Function(int) formatCurrency;
  final VoidCallback onApplyOptimized;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AntarSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: theme.colorScheme.primary),
                    const SizedBox(width: AntarSpacing.xs),
                    Text(
                      'Your Plan vs Optimized',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                      tooltip: 'Back to list',
                    ),
                  ],
                ),
                const SizedBox(height: AntarSpacing.sm),
                // Side-by-side stats
                Row(
                  children: [
                    Expanded(
                      child: _PlanCard(
                        title: 'Your Plan',
                        icon: Icons.person,
                        projects: userSelected.length,
                        cost: userCost,
                        beneficiaries: userBeneficiaries,
                        formatCurrency: formatCurrency,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: AntarSpacing.sm),
                    Expanded(
                      child: _PlanCard(
                        title: 'Optimized',
                        icon: Icons.auto_awesome,
                        projects: optimized.selected.length,
                        cost: optimized.totalCost,
                        beneficiaries: optimized.totalBeneficiaries,
                        formatCurrency: formatCurrency,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AntarSpacing.sm),
                // Improvement callout
                if (optimized.totalBeneficiaries > userBeneficiaries &&
                    userBeneficiaries > 0)
                  Card(
                    color: AntarColors.trueHotspot.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AntarSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up,
                              color: AntarColors.trueHotspot),
                          const SizedBox(width: AntarSpacing.xs),
                          Expanded(
                            child: Text(
                              'Optimizer reaches ${((optimized.totalBeneficiaries / userBeneficiaries - 1) * 100).toStringAsFixed(0)}% more beneficiaries',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AntarColors.trueHotspot,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AntarSpacing.sm),
                // Optimized project list
                for (final c in optimized.selected)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      userSelected.any((u) => u.candidateId == c.candidateId)
                          ? Icons.check
                          : Icons.add_circle_outline,
                      color: userSelected.any((u) => u.candidateId == c.candidateId)
                          ? theme.colorScheme.primary
                          : AntarColors.accent,
                    ),
                    title: Text(c.projectLabel),
                    subtitle: Text(
                        '${c.villageName} · ${formatCurrency(c.indicativeCost)}'),
                    trailing: Text(
                      'P ${c.priority.toStringAsFixed(2)}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
          // Apply buttons
          Padding(
            padding: const EdgeInsets.only(top: AntarSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Keep mine'),
                  ),
                ),
                const SizedBox(width: AntarSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApplyOptimized,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Apply optimized'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.icon,
    required this.projects,
    required this.cost,
    required this.beneficiaries,
    required this.formatCurrency,
    required this.color,
  });

  final String title;
  final IconData icon;
  final int projects;
  final int cost;
  final int beneficiaries;
  final String Function(int) formatCurrency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AntarSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(),
            _StatRow(label: 'Projects', value: '$projects'),
            _StatRow(label: 'Cost', value: formatCurrency(cost)),
            _StatRow(
              label: 'Beneficiaries',
              value: beneficiaries >= 1000
                  ? '${(beneficiaries / 1000).toStringAsFixed(1)}k'
                  : '$beneficiaries',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Quadrant _quadrantFromString(String s) {
  switch (s) {
    case 'true_hotspot':
      return Quadrant.trueHotspot;
    case 'silent_gap':
      return Quadrant.silentGap;
    case 'phantom_demand':
      return Quadrant.phantomDemand;
    default:
      return Quadrant.stable;
  }
}
