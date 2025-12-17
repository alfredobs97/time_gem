import 'package:flutter/material.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Lightbulb Icon with Glow Effect
            _buildIcon(colorScheme),
            const SizedBox(height: 40),
            // Title
            Text(
              'Meet Your AI Planning Assistant',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'Discover how Time Gem organizes your day.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Steps Info Box
            _buildStepsBox(context, colorScheme, theme),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.tertiary.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.tertiary.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.lightbulb_rounded,
            size: 48,
            color: colorScheme.onTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildStepsBox(
      BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildStepRow(
            colorScheme,
            theme,
            icon: Icons.task_alt_rounded,
            number: '1',
            text: 'Create your tasks with priorities and time estimates.',
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            colorScheme,
            theme,
            icon: Icons.calendar_month_rounded,
            number: '2',
            text: 'Connect your calendar to see your schedule.',
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            colorScheme,
            theme,
            icon: Icons.auto_awesome_rounded,
            number: '3',
            text:
                'Let our AI find the perfect time slots to get your work done!',
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    ColorScheme colorScheme,
    ThemeData theme, {
    required IconData icon,
    required String number,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
