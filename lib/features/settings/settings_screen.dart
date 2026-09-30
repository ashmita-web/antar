import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/env.dart';
import '../../core/providers.dart';
import '../../theme/tokens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final region = ref.watch(appRegionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final mode = ref.watch(appModeProvider);
    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/welcome'),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'General'),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Region'),
            subtitle: Text(region.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRegionPicker(context, ref, region),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(switch (themeMode) {
              ThemeMode.system => 'System',
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark',
            }),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),
          if (mode != null)
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Switch Mode'),
              subtitle: Text(
                mode == AppMode.citizen ? 'Currently: Citizen' : 'Currently: Official',
              ),
              onTap: () async {
                await ref.read(appModeProvider.notifier).clearMode();
              },
            ),
          const Divider(),
          _SectionHeader(title: 'Data & AI Status'),
          _StatusTile(
            icon: Icons.auto_awesome,
            label: 'Gemini',
            status: Env.hasGemini ? 'Live' : 'Cached (Demo)',
            isLive: Env.hasGemini,
          ),
          _StatusTile(
            icon: Icons.map,
            label: 'Maps',
            status: Env.hasMaps ? 'Google Maps' : 'OpenStreetMap',
            isLive: Env.hasMaps,
          ),
          _StatusTile(
            icon: Icons.cloud,
            label: 'Firebase',
            status: Env.hasFirebase ? 'Connected' : 'Demo Mode',
            isLive: Env.hasFirebase,
          ),
          if (isDemo) ...[
            const Divider(),
            Container(
              margin: const EdgeInsets.all(AntarSpacing.md),
              padding: const EdgeInsets.all(AntarSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(AntarRadius.chip),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: AntarSpacing.sm),
                  Expanded(
                    child: Text(
                      'Running in demo mode with synthetic data. Configure API keys via --dart-define to enable live features.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(),
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ANTAR'),
            subtitle: const Text(
              'AI for Digital Public Infrastructure & Governance',
            ),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showRegionPicker(BuildContext context, WidgetRef ref, AppRegion current) {
    showDialog<AppRegion>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Region'),
        children: AppRegion.values.map((r) {
          final selected = r == current;
          return ListTile(
            title: Text(r.label),
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? Theme.of(context).colorScheme.primary : null,
            ),
            onTap: () {
              ref.read(appRegionProvider.notifier).setRegion(r);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
    final options = {
      ThemeMode.system: 'System',
      ThemeMode.light: 'Light',
      ThemeMode.dark: 'Dark',
    };
    showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Theme'),
        children: [
          for (final entry in options.entries)
            ListTile(
              title: Text(entry.value),
              leading: Icon(
                entry.key == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: entry.key == current
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(entry.key);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'ANTAR',
        applicationVersion: '1.0.0',
        children: [
          const Text(
            'ANTAR compares citizen demand with infrastructure deficit '
            'and funding coverage to surface silent gaps, recommend '
            'high-priority projects, and measure real impact.\n\n'
            'Built for the "Build with AI: Code for Communities" hackathon.',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AntarSpacing.md,
        AntarSpacing.md,
        AntarSpacing.md,
        AntarSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.label,
    required this.status,
    required this.isLive,
  });

  final IconData icon;
  final String label;
  final String status;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AntarSpacing.sm,
          vertical: AntarSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isLive
              ? AntarColors.stable.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AntarRadius.chip),
        ),
        child: Text(
          status,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isLive ? AntarColors.stable : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
