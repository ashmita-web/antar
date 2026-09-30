import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/providers.dart';
import '../../theme/tokens.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(AntarSpacing.lg),
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Logo mark: two overlapping circles
                  SizedBox(
                    height: isWide ? 120 : 96,
                    width: isWide ? 120 : 96,
                    child: CustomPaint(painter: _LogoPainter(theme)),
                  ),
                  const SizedBox(height: AntarSpacing.lg),
                  Text(
                    'ANTAR',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 4,
                    ),
                    semanticsLabel: 'ANTAR',
                  ),
                  const SizedBox(height: AntarSpacing.sm),
                  Text(
                    'Bridging citizen voice and\npublic infrastructure',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  _ModeCard(
                    icon: Icons.record_voice_over,
                    title: 'Citizen — Awaaz',
                    subtitle: 'Report infrastructure needs in your language',
                    color: AntarColors.accent,
                    onTap: () => _selectMode(ref, context, AppMode.citizen),
                  ),
                  const SizedBox(height: AntarSpacing.md),
                  _ModeCard(
                    icon: Icons.dashboard_rounded,
                    title: 'Official — MP Console',
                    subtitle: 'Data-driven planning and budget optimization',
                    color: theme.colorScheme.primary,
                    onTap: () => _selectMode(ref, context, AppMode.official),
                  ),
                  const Spacer(),
                  const SizedBox(height: AntarSpacing.md),
                ],
              ),
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectMode(
    WidgetRef ref,
    BuildContext context,
    AppMode mode,
  ) async {
    await ref.read(appModeProvider.notifier).setMode(mode);
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AntarSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AntarRadius.chip),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AntarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AntarSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.theme);
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;
    final offset = size.width * 0.14;

    final paintLeft = Paint()
      ..color = AntarColors.primary.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final paintRight = Paint()
      ..color = AntarColors.accent.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - offset, cy), r, paintLeft);
    canvas.drawCircle(Offset(cx + offset, cy), r, paintRight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
