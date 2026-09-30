import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/models/citizen_request.dart';
import '../../theme/tokens.dart';
import 'citizen_providers.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _textController = TextEditingController();
  final _tts = FlutterTts();
  bool _isRecording = false;
  bool _isProcessing = false;
  _ParsedReport? _parsed;

  @override
  void dispose() {
    _textController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(citizenLanguageProvider);

    if (_parsed != null) {
      return _WeUnderstoodCard(
        parsed: _parsed!,
        language: lang,
        onConfirm: _submitReport,
        onEdit: () => setState(() => _parsed = null),
        tts: _tts,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AntarSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What does your community need?',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AntarSpacing.xs),
          Text(
            'Describe the problem in your own words — speak or type.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AntarSpacing.md),

          // Language indicator
          Row(
            children: [
              Icon(Icons.translate, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Speaking in: ${_langName(lang)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AntarSpacing.sm),

          // Voice input button
          Center(
            child: GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? theme.colorScheme.error
                      : theme.colorScheme.primaryContainer,
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.error.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 40,
                  color: _isRecording
                      ? theme.colorScheme.onError
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AntarSpacing.xs),
              child: Text(
                _isRecording ? 'Tap to stop' : 'Tap to speak',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _isRecording
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: AntarSpacing.md),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AntarSpacing.sm),
                child: Text(
                  'or type below',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AntarSpacing.sm),

          // Text input
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _hintForLang(lang),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AntarSpacing.md),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () => _processInput(_textController.text),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isProcessing ? 'Understanding...' : 'Submit'),
            ),
          ),
          const SizedBox(height: AntarSpacing.md),

        ],
      ),
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() => _isRecording = false);
      _processInput(_demoTranscript());
    } else {
      setState(() => _isRecording = true);
    }
  }

  Future<void> _processInput(String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the problem first')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final parsed = _demoParse(text);
    setState(() {
      _isProcessing = false;
      _parsed = parsed;
    });
  }

  void _submitReport() {
    if (_parsed == null) return;
    final lang = ref.read(citizenLanguageProvider);
    final rng = Random();

    final request = CitizenRequest(
      requestId: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      villageCode: 'Village_${100 + rng.nextInt(200)}',
      villageName: 'My Village',
      block: 'My Block',
      timestamp: DateTime.now().toIso8601String(),
      language: lang,
      languageName: _langName(lang),
      category: _parsed!.category,
      subtype: _parsed!.subtype,
      severity: _parsed!.severity,
      peopleAffectedEstimate: _parsed!.peopleAffected,
      transcriptEn: _parsed!.originalText,
      summaryEn: _parsed!.summary,
      status: 'submitted',
      synthetic: true,
    );

    ref.read(myRequestsProvider.notifier).add(request);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted — thank you!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _parsed = null;
      _textController.clear();
    });
  }

  _ParsedReport _demoParse(String text) {
    final lower = text.toLowerCase();
    String category = 'road';
    String subtype = 'pucca_road';
    int severity = 3;
    int affected = 200;
    String summary = 'Road repair needed in the village';

    if (lower.contains('water') || lower.contains('pani') || lower.contains('jal')) {
      category = 'water';
      subtype = 'tap_water_scheme';
      severity = 4;
      affected = 350;
      summary = 'Clean drinking water supply needed';
    } else if (lower.contains('toilet') || lower.contains('sanitation') || lower.contains('sauchalay')) {
      category = 'sanitation';
      subtype = 'community_toilet';
      severity = 4;
      affected = 250;
      summary = 'Community sanitation facility needed';
    } else if (lower.contains('electric') || lower.contains('bijli') || lower.contains('light')) {
      category = 'electricity';
      subtype = 'solar_electrification';
      severity = 3;
      affected = 400;
      summary = 'Electricity supply and street lighting needed';
    } else if (lower.contains('hospital') || lower.contains('health') || lower.contains('doctor')) {
      category = 'health';
      subtype = 'health_subcenter';
      severity = 5;
      affected = 500;
      summary = 'Healthcare facility needed in the area';
    } else if (lower.contains('school') || lower.contains('education') || lower.contains('vidyalaya')) {
      category = 'education';
      subtype = 'primary_school';
      severity = 3;
      affected = 150;
      summary = 'Education facility needed for children';
    } else if (lower.contains('internet') || lower.contains('wifi') || lower.contains('network')) {
      category = 'internet';
      subtype = 'internet_tower';
      severity = 2;
      affected = 300;
      summary = 'Internet connectivity needed';
    } else if (lower.contains('bank') || lower.contains('atm') || lower.contains('paisa')) {
      category = 'banking';
      subtype = 'banking_csp';
      severity = 3;
      affected = 250;
      summary = 'Banking and ATM access needed';
    } else if (lower.contains('bus') || lower.contains('transport') || lower.contains('yatayat')) {
      category = 'transport';
      subtype = 'bus_shelter';
      severity = 2;
      affected = 300;
      summary = 'Public transport connection needed';
    }

    return _ParsedReport(
      category: category,
      subtype: subtype,
      severity: severity,
      peopleAffected: affected,
      summary: summary,
      originalText: text,
    );
  }

  String _demoTranscript() {
    final lang = ref.read(citizenLanguageProvider);
    return switch (lang) {
      'hi' => 'Hamare gaon mein sadak bahut kharab hai, barish mein paani bhar jaata hai',
      'ta' => 'Engal gramathil saalaigal romba moshamaaga irukkindrana',
      'bn' => 'Amader gramer rasta khub kharap, brishti hole jol jome jai',
      'pt' => 'A estrada na nossa aldeia está muito danificada',
      _ => 'The road in our village is very damaged, water collects during rain',
    };
  }

  String _hintForLang(String lang) => switch (lang) {
        'hi' => 'अपनी समस्या यहाँ लिखें...',
        'ta' => 'உங்கள் பிரச்சினையை இங்கே எழுதுங்கள்...',
        'bn' => 'আপনার সমস্যা এখানে লিখুন...',
        'pt' => 'Descreva o problema aqui...',
        _ => 'Describe your problem here...',
      };

  String _langName(String code) => switch (code) {
        'hi' => 'Hindi',
        'en' => 'English',
        'ta' => 'Tamil',
        'bn' => 'Bengali',
        'pt' => 'Portuguese',
        _ => code,
      };
}

class _ParsedReport {
  final String category;
  final String subtype;
  final int severity;
  final int peopleAffected;
  final String summary;
  final String originalText;

  const _ParsedReport({
    required this.category,
    required this.subtype,
    required this.severity,
    required this.peopleAffected,
    required this.summary,
    required this.originalText,
  });
}

class _WeUnderstoodCard extends StatelessWidget {
  const _WeUnderstoodCard({
    required this.parsed,
    required this.language,
    required this.onConfirm,
    required this.onEdit,
    required this.tts,
  });

  final _ParsedReport parsed;
  final String language;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  final FlutterTts tts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AntarSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(AntarSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: AntarSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'We understood!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Here\'s what we heard — please confirm or edit.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AntarSpacing.md),

          // Parsed details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AntarSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Category',
                    value: _categoryLabel(parsed.category),
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.summarize,
                    label: 'Summary',
                    value: parsed.summary,
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.warning_amber,
                    label: 'Severity',
                    value: '${'★' * parsed.severity}${'☆' * (5 - parsed.severity)}',
                  ),
                  const Divider(),
                  _DetailRow(
                    icon: Icons.people,
                    label: 'People affected (approx.)',
                    value: '~${parsed.peopleAffected}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AntarSpacing.sm),

          // Your words
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(AntarSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Your words',
                          style: theme.textTheme.labelMedium),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        tooltip: 'Read aloud',
                        onPressed: () => _speak(parsed.summary),
                      ),
                    ],
                  ),
                  Text(
                    parsed.originalText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AntarSpacing.lg),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AntarSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirm & Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _speak(String text) {
    tts.setLanguage(language == 'hi' ? 'hi-IN' : 'en-US');
    tts.speak(text);
  }

  String _categoryLabel(String cat) =>
      cat[0].toUpperCase() + cat.substring(1);
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AntarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
