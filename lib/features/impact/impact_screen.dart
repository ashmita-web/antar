import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/candidate_project.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';

final _projectStatusProvider =
    StateNotifierProvider<_ProjectStatusNotifier, Map<String, _ProjectStatus>>(
  (ref) => _ProjectStatusNotifier(),
);

enum _ProjectStage { planned, inProgress, completed }

class _ProjectStatus {
  final _ProjectStage stage;
  final double? rating;
  final String? feedback;

  const _ProjectStatus({
    this.stage = _ProjectStage.planned,
    this.rating,
    this.feedback,
  });

  _ProjectStatus copyWith({
    _ProjectStage? stage,
    double? rating,
    String? feedback,
  }) =>
      _ProjectStatus(
        stage: stage ?? this.stage,
        rating: rating ?? this.rating,
        feedback: feedback ?? this.feedback,
      );
}

class _ProjectStatusNotifier extends StateNotifier<Map<String, _ProjectStatus>> {
  _ProjectStatusNotifier() : super({});

  void updateStage(String id, _ProjectStage stage) {
    final current = state[id] ?? const _ProjectStatus();
    state = {...state, id: current.copyWith(stage: stage)};
  }

  void addRating(String id, double rating, String feedback) {
    final current = state[id] ?? const _ProjectStatus();
    state = {
      ...state,
      id: current.copyWith(rating: rating, feedback: feedback),
    };
  }
}

class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(candidatesProvider);
    final statuses = ref.watch(_projectStatusProvider);

    return candidatesAsync.when(
      data: (candidates) => _ImpactBody(
        candidates: candidates,
        statuses: statuses,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ImpactBody extends ConsumerWidget {
  const _ImpactBody({
    required this.candidates,
    required this.statuses,
  });

  final List<CandidateProject> candidates;
  final Map<String, _ProjectStatus> statuses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final completed = statuses.values
        .where((s) => s.stage == _ProjectStage.completed)
        .length;
    final inProgress = statuses.values
        .where((s) => s.stage == _ProjectStage.inProgress)
        .length;
    final rated =
        statuses.values.where((s) => s.rating != null).length;
    final avgRating = rated > 0
        ? statuses.values
                .where((s) => s.rating != null)
                .map((s) => s.rating!)
                .reduce((a, b) => a + b) /
            rated
        : 0.0;

    // Impact score: weighted combo of completion and satisfaction
    final impactScore = candidates.isEmpty
        ? 0.0
        : ((completed / candidates.length.clamp(1, 999)) * 0.6 +
                (avgRating / 5.0) * 0.4) *
            100;

    final top20 = candidates.take(20).toList();

    return Column(
      children: [
        // Impact score header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AntarSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
          ),
          child: Column(
            children: [
              Text('Impact Score', style: theme.textTheme.titleMedium),
              const SizedBox(height: AntarSpacing.xs),
              Text(
                impactScore.toStringAsFixed(0),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'out of 100',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AntarSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(
                    label: 'In Progress',
                    value: '$inProgress',
                    icon: Icons.engineering,
                    color: Colors.orange,
                  ),
                  _MiniStat(
                    label: 'Completed',
                    value: '$completed',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _MiniStat(
                    label: 'Avg Rating',
                    value: rated > 0 ? avgRating.toStringAsFixed(1) : '—',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Project list with status controls
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AntarSpacing.md),
            itemCount: top20.length,
            itemBuilder: (context, i) {
              final c = top20[i];
              final status =
                  statuses[c.candidateId] ?? const _ProjectStatus();
              return _ImpactProjectCard(
                candidate: c,
                status: status,
                onStageChanged: (stage) => ref
                    .read(_projectStatusProvider.notifier)
                    .updateStage(c.candidateId, stage),
                onRate: (rating, feedback) => ref
                    .read(_projectStatusProvider.notifier)
                    .addRating(c.candidateId, rating, feedback),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _ImpactProjectCard extends StatelessWidget {
  const _ImpactProjectCard({
    required this.candidate,
    required this.status,
    required this.onStageChanged,
    required this.onRate,
  });

  final CandidateProject candidate;
  final _ProjectStatus status;
  final ValueChanged<_ProjectStage> onStageChanged;
  final void Function(double rating, String feedback) onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stageColor = switch (status.stage) {
      _ProjectStage.planned => theme.colorScheme.outlineVariant,
      _ProjectStage.inProgress => Colors.orange,
      _ProjectStage.completed => Colors.green,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AntarSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AntarSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stageColor,
                  ),
                ),
                const SizedBox(width: AntarSpacing.xs),
                Expanded(
                  child: Text(
                    candidate.projectLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (status.rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(
                        ' ${status.rating!.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
              ],
            ),
            Text(
              '${candidate.villageName} · ${candidate.block}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AntarSpacing.xs),
            // Stage controls
            Row(
              children: [
                _StageChip(
                  label: 'Planned',
                  active: status.stage == _ProjectStage.planned,
                  onTap: () => onStageChanged(_ProjectStage.planned),
                ),
                const SizedBox(width: 4),
                _StageChip(
                  label: 'In Progress',
                  active: status.stage == _ProjectStage.inProgress,
                  color: Colors.orange,
                  onTap: () => onStageChanged(_ProjectStage.inProgress),
                ),
                const SizedBox(width: 4),
                _StageChip(
                  label: 'Completed',
                  active: status.stage == _ProjectStage.completed,
                  color: Colors.green,
                  onTap: () => onStageChanged(_ProjectStage.completed),
                ),
                const Spacer(),
                if (status.stage == _ProjectStage.completed &&
                    status.rating == null)
                  TextButton.icon(
                    onPressed: () => _showRatingDialog(context),
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Rate'),
                  ),
              ],
            ),
            if (status.feedback != null) ...[
              const SizedBox(height: 4),
              Text(
                '"${status.feedback}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    double tempRating = 3.0;
    final feedbackCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Rate this project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(candidate.projectLabel),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < tempRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () =>
                        setDialogState(() => tempRating = i + 1.0),
                  );
                }),
              ),
              TextField(
                controller: feedbackCtrl,
                decoration: const InputDecoration(
                  hintText: 'Optional feedback...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onRate(tempRating, feedbackCtrl.text);
                Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({
    required this.label,
    required this.active,
    this.color,
    required this.onTap,
  });
  final String label;
  final bool active;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AntarRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? chipColor.withValues(alpha: 0.2) : null,
          border: Border.all(
            color: active ? chipColor : theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AntarRadius.chip),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: active ? chipColor : theme.colorScheme.onSurfaceVariant,
            fontWeight: active ? FontWeight.w600 : null,
          ),
        ),
      ),
    );
  }
}
