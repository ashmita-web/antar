import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/models/citizen_request.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../theme/tokens.dart';
import 'citizen_providers.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  final _tts = FlutterTts();

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myRequests = ref.watch(myRequestsProvider);
    final allRequestsAsync = ref.watch(requestsProvider);

    return allRequestsAsync.when(
      data: (allRequests) {
        final combined = [...myRequests, ...allRequests.take(20)];

        if (combined.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 64, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: AntarSpacing.sm),
                Text(
                  'No requests yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AntarSpacing.xs),
                Text(
                  'Report a need to see it here',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (myRequests.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AntarSpacing.sm),
                color: theme.colorScheme.primaryContainer,
                child: Text(
                  '${myRequests.length} report(s) submitted this session',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AntarSpacing.md),
                itemCount: combined.length,
                itemBuilder: (context, i) {
                  final isMyRequest = i < myRequests.length;
                  return _RequestCard(
                    request: combined[i],
                    isMyRequest: isMyRequest,
                    onSpeak: () => _speak(combined[i]),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _speak(CitizenRequest request) {
    final lang = request.language == 'hi' ? 'hi-IN' : 'en-US';
    _tts.setLanguage(lang);
    _tts.speak(request.summaryEn);
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isMyRequest,
    required this.onSpeak,
  });

  final CitizenRequest request;
  final bool isMyRequest;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AntarSpacing.sm),
      color: isMyRequest ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AntarSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _categoryIcon(request.category),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AntarSpacing.xs),
                Expanded(
                  child: Text(
                    request.summaryEn,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMyRequest)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AntarRadius.chip),
                    ),
                    child: Text(
                      'You',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${request.villageName} · ${request.block}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  request.languageName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _SeverityStars(severity: request.severity),
                const SizedBox(width: AntarSpacing.sm),
                Text(
                  '~${request.peopleAffectedEstimate} affected',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                _StatusBadge(status: request.status),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 18),
                  onPressed: onSpeak,
                  tooltip: 'Read aloud',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
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

class _SeverityStars extends StatelessWidget {
  const _SeverityStars({required this.severity});
  final int severity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < severity ? Icons.star : Icons.star_border,
          size: 14,
          color: i < severity ? Colors.amber : Colors.grey,
        );
      }),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'submitted' => (Colors.blue, 'Submitted'),
      'acknowledged' => (Colors.orange, 'Ack\'d'),
      'in_progress' => (Colors.purple, 'In progress'),
      'completed' => (Colors.green, 'Done'),
      _ => (Colors.grey, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AntarRadius.chip),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
